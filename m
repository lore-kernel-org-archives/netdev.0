From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 09/17] net: hns: modify buffer format of cpu data to le64
Date: Wed, 9 Nov 2016 18:13:53 +0000
Message-ID: <20161109181401.913728-10-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55051 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754712AbcKISPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:15:38 -0500
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

Hardware ring buffer data is stored in Little-endian. Thus cpu data
should be modified to Little-endian.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index e093cbf..b0f0557 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -590,7 +590,7 @@ static inline int hnae_alloc_buffer_attach(struct hnae_ring *ring, int i)
 	if (ret)
 		return ret;
 
-	ring->desc[i].addr = (__le64)ring->desc_cb[i].dma;
+	ring->desc[i].addr = cpu_to_le64(ring->desc_cb[i].dma);
 
 	return 0;
 }
@@ -621,14 +621,14 @@ static inline void hnae_replace_buffer(struct hnae_ring *ring, int i,
 
 	bops->unmap_buffer(ring, &ring->desc_cb[i]);
 	ring->desc_cb[i] = *res_cb;
-	ring->desc[i].addr = (__le64)ring->desc_cb[i].dma;
+	ring->desc[i].addr = cpu_to_le64(ring->desc_cb[i].dma);
 	ring->desc[i].rx.ipoff_bnum_pid_flag = 0;
 }
 
 static inline void hnae_reuse_buffer(struct hnae_ring *ring, int i)
 {
 	ring->desc_cb[i].reuse_flag = 0;
-	ring->desc[i].addr = (__le64)(ring->desc_cb[i].dma
+	ring->desc[i].addr = cpu_to_le64(ring->desc_cb[i].dma
 		+ ring->desc_cb[i].page_offset);
 	ring->desc[i].rx.ipoff_bnum_pid_flag = 0;
 }
-- 
1.7.9.5
