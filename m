From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] ibmvnic: fix missing unlock on error in __ibmvnic_reset()
Date: Thu, 18 May 2017 15:24:52 +0000
Message-ID: <20170518152452.8606-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36724 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932767AbdERPZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:25:02 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so6157212pfb.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 08:25:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Add the missing unlock before return from function __ibmvnic_reset()
in the error handling case.

Fixes: ed651a10875f ("ibmvnic: Updated reset handling")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4f2d329..27f7933 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1313,6 +1313,7 @@ static void __ibmvnic_reset(struct work_struct *work)
 
 	if (rc) {
 		free_all_rwi(adapter);
+		mutex_unlock(&adapter->reset_lock);
 		return;
 	}
