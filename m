From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] ATM-iphase: Adjust four checks for null pointers
Date: Sun, 6 Aug 2017 08:30:12 +0200
Message-ID: <693faecc-81ea-6d85-788c-b42924a2afb1@users.sourceforge.net>
References: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 5 Aug 2017 22:30:04 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/iphase.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index ad4c1b41ba98..19782fed572a 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -101,7 +101,7 @@ static void ia_init_rtn_q (IARTN_Q *que)
 static void ia_enque_head_rtn_q (IARTN_Q *que, IARTN_Q * data) 
 {
    data->next = NULL;
-   if (que->next == NULL) 
+	if (!que->next)
       que->next = que->tail = data;
    else {
       data->next = que->next;
@@ -116,7 +116,7 @@ static int ia_enque_rtn_q (IARTN_Q *que, struct desc_tbl_t data) {
       return -ENOMEM;
    entry->data = data;
    entry->next = NULL;
-   if (que->next == NULL) 
+	if (!que->next)
       que->next = que->tail = entry;
    else {
       que->tail->next = entry;
@@ -127,7 +127,7 @@ static int ia_enque_rtn_q (IARTN_Q *que, struct desc_tbl_t data) {
 
 static IARTN_Q * ia_deque_rtn_q (IARTN_Q *que) {
    IARTN_Q *tmpdata;
-   if (que->next == NULL)
+	if (!que->next)
       return NULL;
    tmpdata = que->next;
    if ( que->next == que->tail)  
@@ -1321,7 +1321,7 @@ static void rx_dle_intr(struct atm_dev *dev)
               goto INCR_DLE;
           }
           ia_vcc = INPH_IA_VCC(vcc);
-          if (ia_vcc == NULL)
+		if (!ia_vcc)
           {
              atomic_inc(&vcc->stats->rx_err);
              atm_return(vcc, skb->truesize);
-- 
2.13.4
