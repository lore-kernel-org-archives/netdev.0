From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 2/2] isdn/gigaset: remove dummy CAPI method implementations
Date: Sun, 23 May 2010 03:15:43 +0200 (CEST)
Message-ID: <20100523-patch-gigaset-02.tilman@imap.cc>
References: <20100523-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>,
        Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20100523-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/options/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper/>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Dummy implementations for the optional CAPI controller operations
load_firmware and reset_ctr can cause userspace callers to hang
indefinitely. It's better not to implement them at all.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---
 drivers/isdn/gigaset/capi.c |   28 ++--------------------------
 1 files changed, 2 insertions(+), 26 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 964a55f..e72f86b 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -933,30 +933,6 @@ void gigaset_isdn_stop(struct cardstate *cs)
  */
 
 /*
- * load firmware
- */
-static int gigaset_load_firmware(struct capi_ctr *ctr, capiloaddata *data)
-{
-	struct cardstate *cs = ctr->driverdata;
-
-	/* AVM specific operation, not needed for Gigaset -- ignore */
-	dev_notice(cs->dev, "load_firmware ignored\n");
-
-	return 0;
-}
-
-/*
- * reset (deactivate) controller
- */
-static void gigaset_reset_ctr(struct capi_ctr *ctr)
-{
-	struct cardstate *cs = ctr->driverdata;
-
-	/* AVM specific operation, not needed for Gigaset -- ignore */
-	dev_notice(cs->dev, "reset_ctr ignored\n");
-}
-
-/*
  * register CAPI application
  */
 static void gigaset_register_appl(struct capi_ctr *ctr, u16 appl,
@@ -2213,8 +2189,8 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	iif->ctr.driverdata    = cs;
 	strncpy(iif->ctr.name, isdnid, sizeof(iif->ctr.name));
 	iif->ctr.driver_name   = "gigaset";
-	iif->ctr.load_firmware = gigaset_load_firmware;
-	iif->ctr.reset_ctr     = gigaset_reset_ctr;
+	iif->ctr.load_firmware = NULL;
+	iif->ctr.reset_ctr     = NULL;
 	iif->ctr.register_appl = gigaset_register_appl;
 	iif->ctr.release_appl  = gigaset_release_appl;
 	iif->ctr.send_message  = gigaset_send_message;
-- 
1.6.5.3.298.g39add
