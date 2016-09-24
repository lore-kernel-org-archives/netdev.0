From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 5/6] mISDN: mark symbols static where possible
Date: Sat, 24 Sep 2016 13:26:08 +0800
Message-ID: <1474694768-7673-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a few warnings when building kernel with W=1:
drivers/isdn/mISDN/layer2.c:120:1: warning: no previous declaration for 'l2headersize' [-Wmissing-declarations]
drivers/isdn/mISDN/layer2.c:127:1: warning: no previous declaration for 'l2addrsize' [-Wmissing-declarations]
drivers/isdn/mISDN/layer2.c:379:1: warning: no previous declaration for 'cansend' [-Wmissing-declarations]
drivers/isdn/mISDN/layer2.c:679:1: warning: no previous declaration for 'stop_t200' [-Wmissing-declarations]
....

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
So this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/mISDN/layer2.c | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 5eb380a..f6ab6027 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -116,14 +116,14 @@ l2m_debug(struct FsmInst *fi, char *fmt, ...)
 	va_end(va);
 }
 
-inline u_int
+static inline u_int
 l2headersize(struct layer2 *l2, int ui)
 {
 	return ((test_bit(FLG_MOD128, &l2->flag) && (!ui)) ? 2 : 1) +
 		(test_bit(FLG_LAPD, &l2->flag) ? 2 : 1);
 }
 
-inline u_int
+static inline u_int
 l2addrsize(struct layer2 *l2)
 {
 	return test_bit(FLG_LAPD, &l2->flag) ? 2 : 1;
@@ -375,7 +375,7 @@ ReleaseWin(struct layer2 *l2)
 		       "isdnl2 freed %d skbuffs in release\n", cnt);
 }
 
-inline unsigned int
+static inline unsigned int
 cansend(struct layer2 *l2)
 {
 	unsigned int p1;
@@ -387,7 +387,7 @@ cansend(struct layer2 *l2)
 	return (p1 < l2->window) && !test_bit(FLG_PEER_BUSY, &l2->flag);
 }
 
-inline void
+static inline void
 clear_exception(struct layer2 *l2)
 {
 	test_and_clear_bit(FLG_ACK_PEND, &l2->flag);
@@ -435,25 +435,25 @@ enqueue_ui(struct layer2 *l2, struct sk_buff *skb)
 		dev_kfree_skb(skb);
 }
 
-inline int
+static inline int
 IsUI(u_char *data)
 {
 	return (data[0] & 0xef) == UI;
 }
 
-inline int
+static inline int
 IsUA(u_char *data)
 {
 	return (data[0] & 0xef) == UA;
 }
 
-inline int
+static inline int
 IsDM(u_char *data)
 {
 	return (data[0] & 0xef) == DM;
 }
 
-inline int
+static inline int
 IsDISC(u_char *data)
 {
 	return (data[0] & 0xef) == DISC;
@@ -468,7 +468,7 @@ IsRR(u_char *data, struct layer2 *l2)
 		return (data[0] & 0xf) == 1;
 }
 
-inline int
+static inline int
 IsSFrame(u_char *data, struct layer2 *l2)
 {
 	register u_char d = *data;
@@ -478,7 +478,7 @@ IsSFrame(u_char *data, struct layer2 *l2)
 	return ((d & 0xf3) == 1) && ((d & 0x0c) != 0x0c);
 }
 
-inline int
+static inline int
 IsSABME(u_char *data, struct layer2 *l2)
 {
 	u_char d = data[0] & ~0x10;
@@ -486,20 +486,20 @@ IsSABME(u_char *data, struct layer2 *l2)
 	return test_bit(FLG_MOD128, &l2->flag) ? d == SABME : d == SABM;
 }
 
-inline int
+static inline int
 IsREJ(u_char *data, struct layer2 *l2)
 {
 	return test_bit(FLG_MOD128, &l2->flag) ?
 		data[0] == REJ : (data[0] & 0xf) == REJ;
 }
 
-inline int
+static inline int
 IsFRMR(u_char *data)
 {
 	return (data[0] & 0xef) == FRMR;
 }
 
-inline int
+static inline int
 IsRNR(u_char *data, struct layer2 *l2)
 {
 	return test_bit(FLG_MOD128, &l2->flag) ?
@@ -645,13 +645,13 @@ send_uframe(struct layer2 *l2, struct sk_buff *skb, u_char cmd, u_char cr)
 }
 
 
-inline u_char
+static inline u_char
 get_PollFlag(struct layer2 *l2, struct sk_buff *skb)
 {
 	return skb->data[l2addrsize(l2)] & 0x10;
 }
 
-inline u_char
+static inline u_char
 get_PollFlagFree(struct layer2 *l2, struct sk_buff *skb)
 {
 	u_char PF;
@@ -661,28 +661,28 @@ get_PollFlagFree(struct layer2 *l2, struct sk_buff *skb)
 	return PF;
 }
 
-inline void
+static inline void
 start_t200(struct layer2 *l2, int i)
 {
 	mISDN_FsmAddTimer(&l2->t200, l2->T200, EV_L2_T200, NULL, i);
 	test_and_set_bit(FLG_T200_RUN, &l2->flag);
 }
 
-inline void
+static inline void
 restart_t200(struct layer2 *l2, int i)
 {
 	mISDN_FsmRestartTimer(&l2->t200, l2->T200, EV_L2_T200, NULL, i);
 	test_and_set_bit(FLG_T200_RUN, &l2->flag);
 }
 
-inline void
+static inline void
 stop_t200(struct layer2 *l2, int i)
 {
 	if (test_and_clear_bit(FLG_T200_RUN, &l2->flag))
 		mISDN_FsmDelTimer(&l2->t200, i);
 }
 
-inline void
+static inline void
 st5_dl_release_l2l3(struct layer2 *l2)
 {
 	int pr;
@@ -694,7 +694,7 @@ st5_dl_release_l2l3(struct layer2 *l2)
 	l2up_create(l2, pr, 0, NULL);
 }
 
-inline void
+static inline void
 lapb_dl_release_l2l3(struct layer2 *l2, int f)
 {
 	if (test_bit(FLG_LAPB, &l2->flag))
@@ -1129,7 +1129,7 @@ enquiry_cr(struct layer2 *l2, u_char typ, u_char cr, u_char pf)
 	enqueue_super(l2, skb);
 }
 
-inline void
+static inline void
 enquiry_response(struct layer2 *l2)
 {
 	if (test_bit(FLG_OWN_BUSY, &l2->flag))
@@ -1139,7 +1139,7 @@ enquiry_response(struct layer2 *l2)
 	test_and_clear_bit(FLG_ACK_PEND, &l2->flag);
 }
 
-inline void
+static inline void
 transmit_enquiry(struct layer2 *l2)
 {
 	if (test_bit(FLG_OWN_BUSY, &l2->flag))
-- 
2.7.4
