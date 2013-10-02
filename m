From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 10/19 v2] net: myri10ge: Change variable type to bool
Date: Wed,  2 Oct 2013 14:19:50 +0200
Message-ID: <1380716391-20214-3-git-send-email-peter.senna@gmail.com>
References: <1380716391-20214-1-git-send-email-peter.senna@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: hykim@myri.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380716391-20214-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is the rc variable on both myri10ge_ss_lock_napi and
myri10ge_ss_lock_poll functions. In both cases rc is only assigned the
values true and false. Both functions already return bool. Change rc
type to bool.

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

 drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 149355b..7792264 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -934,7 +934,7 @@ static inline void myri10ge_ss_init_lock(struct myri10ge_slice_state *ss)
 
 static inline bool myri10ge_ss_lock_napi(struct myri10ge_slice_state *ss)
 {
-	int rc = true;
+	bool rc = true;
 	spin_lock(&ss->lock);
 	if ((ss->state & SLICE_LOCKED)) {
 		WARN_ON((ss->state & SLICE_STATE_NAPI));
@@ -957,7 +957,7 @@ static inline void myri10ge_ss_unlock_napi(struct myri10ge_slice_state *ss)
 
 static inline bool myri10ge_ss_lock_poll(struct myri10ge_slice_state *ss)
 {
-	int rc = true;
+	bool rc = true;
 	spin_lock_bh(&ss->lock);
 	if ((ss->state & SLICE_LOCKED)) {
 		ss->state |= SLICE_STATE_POLL_YIELD;
-- 
1.8.3.1
