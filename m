From: Troy Wilson <tcw@tempest.prismnet.com>
Subject: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 5 Sep 2002 13:30:22 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209051830.g85IUMdH096254@tempest.prismnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
  I've got some early SPECWeb [*] results with 2.5.33 and TSO on e1000.  I
get 2906 simultaneous connections, 99.2% conforming (i.e. faster than the
320 kbps cutoff), at 0% idle with TSO on.  For comparison, with 2.5.25, I 
got 2656, and with 2.5.29 I got 2662, (both 99+% conformance and 0% idle) so
TSO and 2.5.33 look like a Big Win.
 
  I'm having trouble testing with TSO off (I changed the #define NETIF_F_TSO
to "0" in include/linux/netdevice.h to turn it off).  I am getting errors.

     NETDEV WATCHDOG: eth1: transmit timed out
     e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex

  That's pushed my SPECWeb results down to below 2500 connections with TSO 
off because of those adapter resets (It is only that one adapter, BTW) and
these results (with TSO off) shouldn't be considered valid.

  eth1 is the only adapter with errors, and they all look like RX overruns.
For comparison:

eth1      Link encap:Ethernet  HWaddr 00:02:B3:9C:F5:9E  
          inet addr:192.168.4.1  Bcast:192.168.4.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:48621378 errors:8890 dropped:8890 overruns:8890 frame:0
          TX packets:64342993 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:3637004554 (3468.5 Mb)  TX bytes:1377740556 (1313.9 Mb)
          Interrupt:61 Base address:0x1200 Memory:fc020000-0 

eth3      Link encap:Ethernet  HWaddr 00:02:B3:A3:47:E7  
          inet addr:192.168.3.1  Bcast:192.168.3.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:37130540 errors:0 dropped:0 overruns:0 frame:0
          TX packets:49061277 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:2774988658 (2646.4 Mb)  TX bytes:3290541711 (3138.1 Mb)
          Interrupt:44 Base address:0x2040 Memory:fe120000-0 

  I'm still working on getting a clean run with TSO off.  If anyone has any
ideas for me about the timeout errors, I'd appreciate the clue.

Thanks,

- Troy


*  SPEC(tm) and the benchmark name SPECweb(tm) are registered
trademarks of the Standard Performance Evaluation Corporation.
This benchmarking was performed for research purposes only,
and is non-compliant, with the following deviations from the
rules -

  1 - It was run on hardware that does not meed the SPEC
      availability-to-the-public criteria.  The machine is
      an engineering sample.

  2 - access_log wasn't kept for full accounting.  It was
      being written, but deleted every 200 seconds.
