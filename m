From: Karsten Keil <keil@b1-systems.de>
Subject: [mISDN PATCH v2 05/19] Reduce stack size in dsp_cmx_send()
Date: Fri, 22 May 2009 23:04:47 +0200
Message-ID: <7cb9e10c66bb4c7e611993420f470d8d82ae6a41.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757409AbZEVVGT@vger.kernel.org>
In-Reply-To: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Seidel <frank@f-seidel.de>

Reduce stack size memory footprint of mISDN_dsp.
(From 1468 bytes for dsp_cmx_send on i386 down to 44).

Signed-off-by: Frank Seidel <frank@f-seidel.de>
Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |    2 +-
 drivers/isdn/mISDN/dsp_cmx.c           |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 3a7c26c..fc76f40 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -104,7 +104,7 @@
  *	If unsure, don't give this parameter.
  *
  * dslot:
- *	NOTE: only one poll value must be given for every card.
+ *	NOTE: only one dslot value must be given for every card.
  *	Also this value must be given for non-E1 cards. If omitted, the E1
  *	card has D-channel on time slot 16, which is default.
  *	If 1..15 or 17..31, an alternate time slot is used for D-channel.
diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 58c43e4..ac84146 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1592,7 +1592,8 @@ dsp_cmx_send(void *arg)
 	struct dsp_conf_member *member;
 	struct dsp *dsp;
 	int mustmix, members;
-	s32 mixbuffer[MAX_POLL+100], *c;
+	static s32 mixbuffer[MAX_POLL+100];
+	s32 *c;
 	u8 *p, *q;
 	int r, rr;
 	int jittercheck = 0, delay, i;
-- 
1.6.0.2
