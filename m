From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH 2/2] atl1: zero out CMB and SBM in atl1_free_ring_resources
Date: Thu, 16 Sep 2010 21:29:47 +0200
Message-ID: <1284665387-10289-3-git-send-email-kronos.it@gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	atl1-devel@lists.sourceforge.net, jcliburn@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55813 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962Ab0IPTar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 15:30:47 -0400
Received: by wwb18 with SMTP id 18so304234wwb.1
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 12:30:46 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
In-Reply-To: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are allocated in atl1_setup_ring_resources, zero out the pointers
in atl1_free_ring_resources (like the other resources).
---
 drivers/net/atlx/atl1.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index bbd6e30..c73be28 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1251,6 +1251,12 @@ static void atl1_free_ring_resources(struct atl1_adapter *adapter)
 
 	rrd_ring->desc = NULL;
 	rrd_ring->dma = 0;
+
+	adapter->cmb.dma = 0;
+	adapter->cmb.cmb = NULL;
+
+	adapter->smb.dma = 0;
+	adapter->smb.smb = NULL;
 }
 
 static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
-- 
1.7.1

