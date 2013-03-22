From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] caif_virtio: fix error return code in cfv_create_genpool()
Date: Fri, 22 Mar 2013 21:16:52 +0800
Message-ID: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:40461 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012Ab3CVNQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 09:16:54 -0400
Received: by mail-bk0-f45.google.com with SMTP id i18so1865921bkv.32
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 06:16:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/caif/caif_virtio.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index f6caa1e..43b1b75 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -424,8 +424,10 @@ static int cfv_create_genpool(struct cfv_info *cfv)
 	cfv->reserved_size = num_possible_cpus() * cfv->ndev->mtu;
 	cfv->reserved_mem = gen_pool_alloc(cfv->genpool,
 					   cfv->reserved_size);
-	if (!cfv->reserved_mem)
+	if (!cfv->reserved_mem) {
+		err = -ENOMEM;
 		goto err;
+	}
 
 	cfv->watermark_tx = virtqueue_get_vring_size(cfv->vq_tx);
 	return 0;
