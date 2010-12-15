From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 02/12] cxgb4: do not read the clock frequency from VPD
Date: Tue, 14 Dec 2010 23:36:45 -0800
Message-ID: <1292398615-26527-3-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28214 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICI004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:18 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7auWp026581
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:56 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7au2g026580
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:56 -0800
In-Reply-To: <1292398615-26527-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to read the clock frequency from VPD, we already get it a bit
later from FW, after any potential adjustments.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index e97521c..6af0452 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -370,7 +370,7 @@ int t4_seeprom_wp(struct adapter *adapter, bool enable)
 static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 {
 	int i, ret;
-	int ec, sn, v2;
+	int ec, sn;
 	u8 vpd[VPD_LEN], csum;
 	unsigned int vpdr_len;
 	const struct t4_vpd_hdr *v;
@@ -408,10 +408,8 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 
 	FIND_VPD_KW(ec, "EC");
 	FIND_VPD_KW(sn, "SN");
-	FIND_VPD_KW(v2, "V2");
 #undef FIND_VPD_KW
 
-	p->cclk = simple_strtoul(vpd + v2, NULL, 10);
 	memcpy(p->id, v->id_data, ID_LEN);
 	strim(p->id);
 	memcpy(p->ec, vpd + ec, EC_LEN);
-- 
1.5.4

