From: Kazunori Kobayashi <kkobayas@igel.co.jp>
Subject: [PATCH] smsc911x: Enable flow control advertisement
Date: Wed, 19 Oct 2011 18:21:54 +0900
Message-ID: <1319016114-4781-1-git-send-email-kkobayas@igel.co.jp>
Cc: steve.glendinning@smsc.com, dhobsong@igel.co.jp,
	Kazunori Kobayashi <kkobayas@igel.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51298 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab1JSJWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 05:22:14 -0400
Received: by yxp4 with SMTP id 4so1469366yxp.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 02:22:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the advertisement of both symmetric pause and asymmetric pause 
flow control capability. 

Signed-off-by: Kazunori Kobayashi <kkobayas@igel.co.jp>
---
 drivers/net/smsc911x.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b9016a3..60c3bc2 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -800,8 +800,13 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 	struct phy_device *phy_dev = pdata->phy_dev;
 	u32 afc = smsc911x_reg_read(pdata, AFC_CFG);
 	u32 flow;
+	u16 miiadv = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
+				       MII_ADVERTISE);
 	unsigned long flags;
 
+	miiadv |= (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_ADVERTISE, miiadv);
+
 	if (phy_dev->duplex == DUPLEX_FULL) {
 		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
 		u16 rmtadv = phy_read(phy_dev, MII_LPA);
-- 
1.7.0.4
