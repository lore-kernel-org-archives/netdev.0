From: John Linn <john.linn@xilinx.com>
Subject: RE: [PATCH 01/12] net: axienet: Support for RGMII
Date: Tue, 5 May 2015 12:54:10 +0000
Message-ID: <8C367E791021814DA6CAFCCCD4EFC2297C97A227@XSJ-PSEXMBX01.xlnx.xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"monstr@monstr.eu" <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>
To: Michal Simek <michals@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0064.outbound.protection.outlook.com ([207.46.100.64]:3584
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423312AbbEENJW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 09:09:22 -0400
Received: from unknown-38-66.xilinx.com ([149.199.38.66]:43256 helo=xsj-pvapsmtp01)
	by xsj-pvapsmtpgw02 with esmtp (Exim 4.63)
	(envelope-from <john.linn@xilinx.com>)
	id 1YpcDy-0007JQ-Ho
	for netdev@vger.kernel.org; Tue, 05 May 2015 05:45:22 -0700
Received: from [127.0.0.1] (helo=xsj-smtp-dlp2.xlnx.xilinx.com)
	by xsj-pvapsmtp01 with esmtp (Exim 4.63)
	(envelope-from <john.linn@xilinx.com>)
	id 1YpcMX-0006Z5-QF
	for netdev@vger.kernel.org; Tue, 05 May 2015 05:54:13 -0700
Received: from xsj-pvapsmtp01 (xsj-smtp.xilinx.com [149.199.38.66])
	by xsj-smtp-dlp2.xlnx.xilinx.com (8.13.8/8.13.1) with ESMTP id t45CrqCm020400
	for <netdev@vger.kernel.org>; Tue, 5 May 2015 05:53:53 -0700
Received: from [172.19.131.25] (helo=XSJ-PVEXCAS01.xlnx.xilinx.com)
	by xsj-pvapsmtp01 with esmtp (Exim 4.63)
	(envelope-from <linnj@xilinx.com>)
	id 1YpcMU-0006Yv-Ps
	for netdev@vger.kernel.org; Tue, 05 May 2015 05:54:10 -0700
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

I removed the mailing lists.

One of the issues we see in the field is that the value of PHY_INTERFACE_MODE_RGMII_ID causes a delay on the RX and TX side in the PHY to align the clock and the data. Yet this does not work on every board such that         PHY_INTERFACE_MODE_RGMII_RXID or        PHY_INTERFACE_MODE_RGMII_TXID must be used.

I realize that's a pain.  Sometimes the PHY driver allows register values (like Marvell) to be setup on the PHY node which helps, but not always.  It seems that the information in the device tree is not adequate to describe the hardware. I've not looked to see what others do as maybe this is a common problem, just thought I should pass on the problem.

Thanks
John

-----Original Message-----
From: Michal Simek [mailto:monstr@monstr.eu] On Behalf Of Michal Simek
Sent: Tuesday, May 05, 2015 4:26 AM
To: netdev@vger.kernel.org
Cc: Srikanth Thokala; Soren Brinkmann; monstr@monstr.eu; John Linn; Anirudha Sarangi; linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org
Subject: [PATCH 01/12] net: axienet: Support for RGMII

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

This patch adds support for the RGMII. The h/w configuration parameter C_PHY_TYPE, which represents the interface configured in the design, is used to differentiate various interfaces supported by AXI Ethernet.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 28b7e7d9c272..0ab607732bb4 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -925,9 +925,16 @@ static int axienet_open(struct net_device *ndev)
                return ret;

        if (lp->phy_node) {
-               lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+               if (lp->phy_type == XAE_PHY_TYPE_GMII) {
+                       lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
                                             axienet_adjust_link, 0,
                                             PHY_INTERFACE_MODE_GMII);
+               } else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
+                       lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+                                            axienet_adjust_link, 0,
+                                            PHY_INTERFACE_MODE_RGMII_ID);
+               }
+
                if (!lp->phy_dev) {
                        dev_err(lp->dev, "of_phy_connect() failed\n");
                        return -ENODEV;
--
2.3.5



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.
