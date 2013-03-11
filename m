From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] bnx2x: use list_move instead of list_del/list_add
Date: Mon, 11 Mar 2013 22:40:14 +0800
Message-ID: <CAPgLHd8f_Vq40sB9SaD-3wsHp34ifQ7X+uoMUNDfjFHcy4wJkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:57889 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab3CKOkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 10:40:16 -0400
Received: by mail-bk0-f53.google.com with SMTP id j10so1761690bkw.12
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 07:40:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move() instead of list_del() + list_add().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 71fcef0..c32a066 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -556,8 +556,7 @@ static int bnx2x_vfop_config_list(struct bnx2x *bp,
 		rc = bnx2x_config_vlan_mac(bp, vlan_mac);
 		if (rc >= 0) {
 			cnt += pos->add ? 1 : -1;
-			list_del(&pos->link);
-			list_add(&pos->link, &rollback_list);
+			list_move(&pos->link, &rollback_list);
 			rc = 0;
 		} else if (rc == -EEXIST) {
 			rc = 0;
