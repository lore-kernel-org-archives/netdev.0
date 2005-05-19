From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: igmp snooping?
Date: Wed, 18 May 2005 18:44:09 -0700
Message-ID: <OF6CAB3867.F641224F-ON88257006.00079FC5-88257006.00098A9E@us.ibm.com>
References: <1116465059.6240.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1116465059.6240.20.camel@localhost.localdomain>
To: hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If you put the interface in multicast promiscuous mode (set flag 
IFF_ALLMULTI),
you can receive all hardware groups without joining.

For IGMP and MLD packets, one way to do that pat in an application is to 
create
a raw socket and specify the protocol there. So, to receive all reports
for any version of IGMP sent to any group, you can create a socket like 
this:

        s = socket(PF_INET, SOCK_RAW, IPPROTO_IGMP);


For MLDv1 and MLDv2 (IPv6), they are part of ICMPv6, but you can use
ICMPV6_FILTER with the MLD report types to receive only those.

You can get the receiving interface as ancillary data on a recvmsg()
call with the IPV6_PKTINFO socket option on Linux systems
(IPV6_RECVPKTINFO when RFC 3542 compliant) for IPv6 and
similarly with IP_PKTINFO with IPv4, I believe. You also can get this
information by restricting the socket to receiving on a particular
interface, if you don't want one socket to handle multiple interfaces.
Then, you know which interface by which socket you received on.

So, you should be able to do most, possibly all, of what you want at
application level without modification to the kernel, if you're looking
to do this in an application and not a kernel module.

                                        +-DLS
