From: akpm@linux-foundation.org
Subject: [patch 4/4] drivers/isdn/hardware/mISDN: move a dereference below a NULL test
Date: Fri, 09 Jan 2009 12:22:53 -0800
Message-ID: <200901092022.n09KMr76019952@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42017 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754797AbZAIUX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:23:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In each case, if the NULL test is necessary, then the dereference should be
moved below the NULL test.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
expression E;
identifier i,fld;
statement S;
@@

- T i = E->fld;
+ T i;
  ... when != E
      when != i
  if (E == NULL) S
+ i = E->fld;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/hfcmulti.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/isdn/hardware/mISDN/hfcmulti.c~drivers-isdn-hardware-misdn-move-a-dereference-below-a-null-test drivers/isdn/hardware/mISDN/hfcmulti.c
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c~drivers-isdn-hardware-misdn-move-a-dereference-below-a-null-test
+++ a/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3610,7 +3610,7 @@ hfcm_bctrl(struct mISDNchannel *ch, u_in
 static void
 ph_state_change(struct dchannel *dch)
 {
-	struct hfc_multi *hc = dch->hw;
+	struct hfc_multi *hc;
 	int ch, i;
 
 	if (!dch) {
@@ -3618,6 +3618,7 @@ ph_state_change(struct dchannel *dch)
 		    __func__);
 		return;
 	}
+	hc = dch->hw;
 	ch = dch->slot;
 
 	if (hc->type == 1) {
_
