From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] bnx2x: use list_move_tail instead of list_del/list_add_tail
Date: Wed, 5 Sep 2012 15:06:55 +0800
Message-ID: <CAPgLHd-P-x3ZqrUMirMBbx74vz1XXNLb-nb3UWa43nVmmwNMCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:47799 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab2IEHG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 03:06:56 -0400
Received: by qaas11 with SMTP id s11so341872qaa.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 00:06:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move_tail() instead of list_del() + list_add_tail().

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 62f754b..5a5fbf5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -229,8 +229,7 @@ static inline int bnx2x_exe_queue_step(struct bnx2x *bp,
 			 */
 			list_add_tail(&spacer.link, &o->pending_comp);
 			mb();
-			list_del(&elem->link);
-			list_add_tail(&elem->link, &o->pending_comp);
+			list_move_tail(&elem->link, &o->pending_comp);
 			list_del(&spacer.link);
 		} else
 			break;
