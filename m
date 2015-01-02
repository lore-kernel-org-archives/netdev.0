From: Felipe Balbi <balbi@ti.com>
Subject: [PATCH 0/4] net: cpsw: fix hangs and improve IRQ handling
Date: Fri, 2 Jan 2015 12:10:24 -0600
Message-ID: <1420222228-31949-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	Yegor Yefremov <yegorslists@googlemail.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, Felipe Balbi <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

patch 1 fixes the bug reported by Yegor Yefremov <yegorslists@googlemail.com>.

patches 2 - 4 improve IRQ handling a little bit.

Tested with BeagleBone Black and AM437x SK. The bug fix has been
tested for almost 3 days non-stop while the following patches
have been tested for a couple of hours with iperf and nuttcp and
NFS root.

Note that we also have a slight throughput improvement after patch 3
when running with AM437x SK (10.0.1.13 below):

===== pre-patch =====

$ iperf -c 10.0.1.13
------------------------------------------------------------
Client connecting to 10.0.1.13, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 10.0.1.2 port 38430 connected with 10.0.1.13 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   240 MBytes   201 Mbits/sec
$ iperf -c 10.0.1.101
------------------------------------------------------------
Client connecting to 10.0.1.101, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 10.0.1.2 port 35143 connected with 10.0.1.101 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   113 MBytes  94.7 Mbits/sec


===== post-patch =====

$ iperf -c 10.0.1.13
------------------------------------------------------------
Client connecting to 10.0.1.13, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 10.0.1.2 port 38447 connected with 10.0.1.13 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   283 MBytes   237 Mbits/sec
$ iperf -c 10.0.1.101
------------------------------------------------------------
Client connecting to 10.0.1.101, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 10.0.1.2 port 35157 connected with 10.0.1.101 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   113 MBytes  94.4 Mbits/sec

That minor decrease on beagleboneblack (10.0.1.101) is so small that's
likely into the error margin, but I'll run some further profiling as
I have a feeling INTC's IRQ handling can be improved.

In any case, patch 1 should go in during the -rc an get backported
all the way back to v3.9, while the other patches can (should) be
delayed for v3.20 merge window.

Felipe Balbi (4):
  net: ethernet: cpsw: fix hangs with interrupts
  net: ethernet: cpsw: unroll IRQ request loop
  net: ethernet: cpsw: split out IRQ handler
  net: ethernet: cpsw: don't requests IRQs we don't use

 drivers/net/ethernet/ti/cpsw.c | 81 +++++++++++++++++++++++++++---------------
 1 file changed, 52 insertions(+), 29 deletions(-)

-- 
2.2.0

