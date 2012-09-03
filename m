From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] mISDN: fix possible memory leak in hfcmulti_init()
Date: Mon, 3 Sep 2012 15:31:00 +0800
Message-ID: <CAPgLHd_vRu-ACoVhf2LwL_1pYXuvXArindYOpHh6T-syn_CVUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:57240 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423Ab2ICHbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 03:31:01 -0400
Received: by qaas11 with SMTP id s11so2049224qaa.19
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2012 00:31:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

hc has been allocated in this function and missing free it before
leaving from some error handling cases.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 5e402cf..f027942 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5059,6 +5059,7 @@ hfcmulti_init(struct hm_map *m, struct pci_dev *pdev,
 				printk(KERN_INFO
 				       "HFC-E1 #%d has overlapping B-channels on fragment #%d\n",
 				       E1_cnt + 1, pt);
+				kfree(hc);
 				return -EINVAL;
 			}
 			maskcheck |= hc->bmask[pt];
@@ -5086,6 +5087,7 @@ hfcmulti_init(struct hm_map *m, struct pci_dev *pdev,
 	if ((poll >> 1) > sizeof(hc->silence_data)) {
 		printk(KERN_ERR "HFCMULTI error: silence_data too small, "
 		       "please fix\n");
+		kfree(hc);
 		return -EINVAL;
 	}
 	for (i = 0; i < (poll >> 1); i++)
