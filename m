From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 09/19 v2] net: bnx2x: Change variable type to bool
Date: Wed,  2 Oct 2013 14:19:49 +0200
Message-ID: <1380716391-20214-2-git-send-email-peter.senna@gmail.com>
References: <1380716391-20214-1-git-send-email-peter.senna@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:45539 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab3JBMUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 08:20:19 -0400
In-Reply-To: <1380716391-20214-1-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable rc is only assigned the values true and false.
The function bnx2x_prev_is_path_marked already returns bool.
Change rc type to bool.

The simplified semantic patch that find this problem is as
follows (http://coccinelle.lip6.fr/):

@exists@
type T;
identifier b;
@@
- T
+ bool
  b = ...;
  ... when any
  b = \(true\|false\)

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
Changes from v1:
 - Added subsystem prefix to shortlog

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fccfc1d..105cc80 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9874,7 +9874,7 @@ static int bnx2x_prev_path_mark_eeh(struct bnx2x *bp)
 static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 {
 	struct bnx2x_prev_path_list *tmp_list;
-	int rc = false;
+	bool rc = false;
 
 	if (down_trylock(&bnx2x_prev_sem))
 		return false;
-- 
1.8.3.1
