From: "Raghurama 'REDDY'" <rreddy@psc.edu>
Subject: Bug or feature: raw sockets ignores IP_DF when packet is bigger than pmtu
Date: Tue, 11 Mar 2003 18:10:35 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <03031118103534.2221577a.8921380@psc.edu>
Reply-To: rreddy@psc.edu
Cc: RREDDY@vms.psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: NETDEV@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please let me know if this is the expected behavior:

    I am running a linux 2.4.20 system.

    The socket type is SOCK_RAW and the protocol is IPPROTO_RAW

    I am filling IP header myself.

    IP_DF is set in the header.

    I have experimented with and without IP_HDRINCL, and it did not make
    difference.  It appears that on Linux, if the protocol and the
    socket are RAW, it does assume the header is included.

For the test:

    The interface MTU is 4470

    Next hop is router with an MTU of 1500

    Packet size being sent out is about 2000 bytes

What is observed on running a program like traceroute with "-M" option
is:

    The first time I run it, I do get "Fragmentation required" message
    as expected.  We can also observe in the tcpdump output that DF is
    set.

    If I run the test again immediately, we can see in the tcpdump
    output on the outging interface that IP fragments the message to
    1500 bytes and sends them out with out setting the DF bit.  This is
    because the route cache has path MTU stored as 1500.

    If I wait for some (until cache expires), or explicitly flush the
    cache with:

    	echo 1 > /proc/sys/net/ipv4/route/flush

    and rerun the test, it works as expected and returns "Fragmentation
    required" packets.

So the conjecture is that IP on the "host" fragments the packets if it
knows the path MTU is not large enough to send the packet with out
fragmentation (even when DF bit is set)

Apparently this is consistent with the IPv6 spec which says that the
routers can not fragment packets, and that hosts may.

Thanks!

--rr
