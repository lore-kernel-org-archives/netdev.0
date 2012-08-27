From: chikazawa.akifu@jp.fujitsu.com (=?ISO-2022-JP?B?GyRCNmFCdBsoQg==?=
	=?ISO-2022-JP?B?IBskQkUvO0sbKEI=?=)
Subject: when the MTU interface is modified, the promiscuous mode is reset in gianfar driver
Date: Mon, 27 Aug 2012 17:38:34 +0900
Message-ID: <201208270838.AA02326@VF09040P.jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

 I am using the gianfar ethernet driver. I am having a problem with the
 interface settings.
 Under promiscuous mode, when the MTU interface is modified, the promiscuous
 mode setting is turned off in gianfar driver when it should not be.
The details are as follows:
 After changing MTU with ifconfig, I could see that the interface flag of
 eth0 is still PROMISC.
 However, when I checked value of RCTL register with ethtool, PROM bit of
 RTCL register is cleared.
 It seems to be cause that is the gfar_init_mac() function, it doesn't set
 the PROM bit after the interface MTU is changed.
 This problem was detected on linux-2.6.32.2, but it seems to same on
 linux-3.6.0-rc3.
Is this behavior on purpose?

I also attach the amended file,I think it would be so.

Signed-off-by: Akifumi Chikazawa <chikazawa.akifu@jp.fujitsu.com>
---
 gianfar.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4605f72..6991e0e 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -389,6 +389,9 @@ static void gfar_init_mac(struct net_device *ndev)
        if (ndev->features & NETIF_F_HW_VLAN_RX)
                rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;

+       if (ndev->flags & IFF_PROMISC)
+               rctrl |= RCTRL_PROM;
+
        /* Init rctrl based on our settings */
        gfar_write(&regs->rctrl, rctrl);

-----------
Fujitsu Computer Technologies Limited
Firmware Engineering Dept.

Akifumi Chikazawa
email: chikazawa.akifu@jp.fujitsu.com
