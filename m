From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4482] New: natsemi: incorrect initialization
 of IPv6 Neighbor-discovery multicast
Date: Wed, 13 Apr 2005 10:36:42 -0700
Message-ID: <20050413103642.172d3976.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: svallet@gmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 13 Apr 2005 07:19:38 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4482] New: natsemi: incorrect initialization of IPv6 Neighbor-discovery multicast


http://bugme.osdl.org/show_bug.cgi?id=4482

           Summary: natsemi: incorrect initialization of IPv6 Neighbor-
                    discovery multicast
    Kernel Version: 2.6.11.7
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: svallet@gmail.com


Distribution: Debian Sarge (testing)

Hardware Environment: 
Arch is PowerPC/BeigeG3
Problematic NIC has a DP83815 chipset (Netgear FA311)

Software Environment:
iproute2/ifconfig

Problem Description:
"ifconfig eth0 up" *apparently* allows multicast on the device :
# ifconfig eth0
...
UP BROADCAST RUNNING MULTICAST
...

# ip maddr show
...
1:   eth0
     link   33:33:ff:be:0a:ed
     link   33:33:00:00:00:01
     ...
     inet6  ff02::1:ffbe:aed
     inet6  ff02::1

However, the NIC does *not* reply to neighbor-sollicitation multicasts, neither
on 33:33:00:00:00:01 (ping6 ff02::1) or on the sollicited-node multicast.

It *is* however responding *after* being brought in promiscuous mode (using
tcpdump) or an "ifconfig eth0 multicast" has been issued. Shuting down and up
brings the problem back again


Steps to reproduce:
# ifconfig eth0 down
# ifconfig eth0 up

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
