From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 2/2] Use correct shift factor for extracting the SGE DMA Ingress Padding ...
Date: Tue, 29 Jun 2010 15:54:12 -0700
Message-ID: <201006291554.12983.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31699 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab0F2W5m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:57:42 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5TMvg2s018102
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 15:57:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From d9aed637fc8a9f1bf1bccf6f23aed0342870f868 Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Tue, 29 Jun 2010 15:15:11 -0700
Subject: [PATCH 2/2] Use correct shift factor for extracting the SGE DMA Ingress Padding
 Boundary.  Was accidentally using the register field's shift which was close
 enough (4 instead of the propper value of 5) that it actually sort of
 worked for various packet sizes ...


Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 5c4a81d..3a7c02f 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -2432,7 +2432,7 @@ int t4vf_sge_init(struct adapter *adapter)
 	STAT_LEN = ((sge_params->sge_control & EGRSTATUSPAGESIZE) ? 128 : 64);
 	PKTSHIFT = PKTSHIFT_GET(sge_params->sge_control);
 	FL_ALIGN = 1 << (INGPADBOUNDARY_GET(sge_params->sge_control) +
-			 INGPADBOUNDARY_SHIFT);
+			 SGE_INGPADBOUNDARY_SHIFT);
 
 	/*
 	 * Set up tasklet timers.
-- 
1.7.0.4

