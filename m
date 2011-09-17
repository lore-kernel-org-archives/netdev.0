From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 1/3] bna: Semaphore Lock Fix
Date: Fri, 16 Sep 2011 18:06:46 -0700
Message-ID: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55776 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932362Ab1IQBIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 21:08:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a BUG_ON() as it is not required.

Change the unconditional write to release a semaphore to read sem first
and then write. This will eliminate the possibility of sem getting locked
while trying to release it in case if previous sem_get operation failed.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 029fb52..4282fef 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1201,13 +1201,13 @@ bfa_nw_ioc_sem_get(void __iomem *sem_reg)
 	if (!(r32 & 1))
 		return true;
 
-	BUG_ON(!(cnt < BFA_SEM_SPINCNT));
 	return false;
 }
 
 void
 bfa_nw_ioc_sem_release(void __iomem *sem_reg)
 {
+	readl(sem_reg);
 	writel(1, sem_reg);
 }
 
-- 
1.7.1
