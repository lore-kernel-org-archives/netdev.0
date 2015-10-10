From: Tillmann Heidsieck <theidsieck@leenox.de>
Subject: [PATCH 1/2] atm: iphase: return -ENOMEM instead of -1 in case of failed kmalloc()
Date: Sat, 10 Oct 2015 21:47:18 +0200
Message-ID: <1444506439-10414-2-git-send-email-theidsieck@leenox.de>
References: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tillmann Heidsieck <theidsieck@leenox.de>
To: Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Smatch complains about returning hard coded error codes, silence this
warning.

drivers/atm/iphase.c:115 ia_enque_rtn_q() warn: returning -1 instead of -ENOMEM is sloppy

Signed-off-by: Tillmann Heidsieck <theidsieck@leenox.de>
---
 drivers/atm/iphase.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 65e65903faa0..d5010d7a99c3 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -112,7 +112,8 @@ static void ia_enque_head_rtn_q (IARTN_Q *que, IARTN_Q * data)
 
 static int ia_enque_rtn_q (IARTN_Q *que, struct desc_tbl_t data) {
    IARTN_Q *entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
-   if (!entry) return -1;
+   if (!entry)
+      return -ENOMEM;
    entry->data = data;
    entry->next = NULL;
    if (que->next == NULL) 
-- 
2.6.1
