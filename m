From: Joe Perches <joe@perches.com>
Subject: [PATCH] irda: Fix build failures after IRDA_DEBUG->pr_debug
Date: Wed, 12 Nov 2014 18:15:47 -0800
Message-ID: <1415844947.4269.5.camel@perches.com>
References: <20141111.162257.701721486580745428.davem@davemloft.net>
	 <1415741850.16070.13.camel@perches.com>
	 <1415745897.16070.15.camel@perches.com>
	 <20141112.135719.707307878615480184.davem@davemloft.net>
	 <1415840172.4269.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0180.hostedemail.com ([216.40.44.180]:60302 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753482AbaKMCPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 21:15:50 -0500
In-Reply-To: <1415840172.4269.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the build failures that result from the use of pr_debug
without the referenced char * arrays being defined.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Wed, 2014-11-12 at 16:56 -0800, Joe Perches wrote:
> On Wed, 2014-11-12 at 13:57 -0500, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Tue, 11 Nov 2014 14:44:57 -0800
> > > Use the normal kernel debugging mechanism which also
> > > enables dynamic_debug at the same time.
> > Applied to net-next, thanks Joe.
> Apologies.
> 
> There was obviously insufficient platform and
> config option testing on this patch.
> 
> David, can you lease revert and I'll work out the
> various platform options defects that have been
> reported by Fengguang's kbuild test robot.

I believe this should fix all the build failures.

Let me know if you want this as a a patch or a
reversion followed by a consolidated new version.

 net/irda/ircomm/ircomm_event.c      | 4 +---
 net/irda/ircomm/ircomm_tty_attach.c | 4 +---
 net/irda/iriap.c                    | 4 +---
 net/irda/irlap.c                    | 4 +---
 net/irda/irlap_event.c              | 4 +---
 net/irda/irlmp_event.c              | 4 +---
 6 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/net/irda/ircomm/ircomm_event.c b/net/irda/ircomm/ircomm_event.c
index 0476da2..b0730ac 100644
--- a/net/irda/ircomm/ircomm_event.c
+++ b/net/irda/ircomm/ircomm_event.c
@@ -54,8 +54,7 @@ const char *const ircomm_state[] = {
 	"IRCOMM_CONN",
 };
 
-#ifdef CONFIG_IRDA_DEBUG
-static const char *const ircomm_event[] = {
+static const char *const ircomm_event[] __maybe_unused = {
 	"IRCOMM_CONNECT_REQUEST",
 	"IRCOMM_CONNECT_RESPONSE",
 	"IRCOMM_TTP_CONNECT_INDICATION",
@@ -73,7 +72,6 @@ static const char *const ircomm_event[] = {
 	"IRCOMM_CONTROL_REQUEST",
 	"IRCOMM_CONTROL_INDICATION",
 };
-#endif /* CONFIG_IRDA_DEBUG */
 
 static int (*state[])(struct ircomm_cb *self, IRCOMM_EVENT event,
 		      struct sk_buff *skb, struct ircomm_info *info) =
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 549ca14..61137f8 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -89,8 +89,7 @@ const char *const ircomm_tty_state[] = {
 	"*** ERROR *** ",
 };
 
-#ifdef CONFIG_IRDA_DEBUG
-static const char *const ircomm_tty_event[] = {
+static const char *const ircomm_tty_event[] __maybe_unused = {
 	"IRCOMM_TTY_ATTACH_CABLE",
 	"IRCOMM_TTY_DETACH_CABLE",
 	"IRCOMM_TTY_DATA_REQUEST",
@@ -106,7 +105,6 @@ static const char *const ircomm_tty_event[] = {
 	"IRCOMM_TTY_GOT_LSAPSEL",
 	"*** ERROR ****",
 };
-#endif /* CONFIG_IRDA_DEBUG */
 
 static int (*state[])(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
 		      struct sk_buff *skb, struct ircomm_tty_info *info) =
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 7a93cdd..4a7ae32a 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -43,9 +43,8 @@
 #include <net/irda/iriap_event.h>
 #include <net/irda/iriap.h>
 
-#ifdef CONFIG_IRDA_DEBUG
 /* FIXME: This one should go in irlmp.c */
-static const char *const ias_charset_types[] = {
+static const char *const ias_charset_types[] __maybe_unused = {
 	"CS_ASCII",
 	"CS_ISO_8859_1",
 	"CS_ISO_8859_2",
@@ -58,7 +57,6 @@ static const char *const ias_charset_types[] = {
 	"CS_ISO_8859_9",
 	"CS_UNICODE"
 };
-#endif	/* CONFIG_IRDA_DEBUG */
 
 static hashbin_t *iriap = NULL;
 static void *service_handle;
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 4b011b7a..7f2cafd 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -60,8 +60,7 @@ static void __irlap_close(struct irlap_cb *self);
 static void irlap_init_qos_capabilities(struct irlap_cb *self,
 					struct qos_info *qos_user);
 
-#ifdef CONFIG_IRDA_DEBUG
-static const char *const lap_reasons[] = {
+static const char *const lap_reasons[] __maybe_unused = {
 	"ERROR, NOT USED",
 	"LAP_DISC_INDICATION",
 	"LAP_NO_RESPONSE",
@@ -71,7 +70,6 @@ static const char *const lap_reasons[] = {
 	"LAP_PRIMARY_CONFLICT",
 	"ERROR, NOT USED",
 };
-#endif	/* CONFIG_IRDA_DEBUG */
 
 int __init irlap_init(void)
 {
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index 245d87b..0e1b4d7 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -78,8 +78,7 @@ static int irlap_state_sclose (struct irlap_cb *self, IRLAP_EVENT event,
 static int irlap_state_reset_check(struct irlap_cb *, IRLAP_EVENT event,
 				   struct sk_buff *, struct irlap_info *);
 
-#ifdef CONFIG_IRDA_DEBUG
-static const char *const irlap_event[] = {
+static const char *const irlap_event[] __maybe_unused = {
 	"DISCOVERY_REQUEST",
 	"CONNECT_REQUEST",
 	"CONNECT_RESPONSE",
@@ -119,7 +118,6 @@ static const char *const irlap_event[] = {
 	"BACKOFF_TIMER_EXPIRED",
 	"MEDIA_BUSY_TIMER_EXPIRED",
 };
-#endif	/* CONFIG_IRDA_DEBUG */
 
 const char *const irlap_state[] = {
 	"LAP_NDM",
diff --git a/net/irda/irlmp_event.c b/net/irda/irlmp_event.c
index 22c019c..e306cf2 100644
--- a/net/irda/irlmp_event.c
+++ b/net/irda/irlmp_event.c
@@ -48,8 +48,7 @@ const char *const irlsap_state[] = {
 	"LSAP_SETUP_PEND",
 };
 
-#ifdef CONFIG_IRDA_DEBUG
-static const char *const irlmp_event[] = {
+static const char *const irlmp_event[] __maybe_unused = {
 	"LM_CONNECT_REQUEST",
 	"LM_CONNECT_CONFIRM",
 	"LM_CONNECT_RESPONSE",
@@ -75,7 +74,6 @@ static const char *const irlmp_event[] = {
 	"LM_LAP_DISCOVERY_CONFIRM",
 	"LM_LAP_IDLE_TIMEOUT",
 };
-#endif	/* CONFIG_IRDA_DEBUG */
 
 /* LAP Connection control proto declarations */
 static void irlmp_state_standby  (struct lap_cb *, IRLMP_EVENT,
