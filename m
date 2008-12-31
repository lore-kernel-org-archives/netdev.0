From: Simon Holm =?ISO-8859-1?Q?Th=F8gersen?= <odie@cs.aau.dk>
Subject: [PATCH] net/rfkill/rfkill.c: fix unused rfkill_led_trigger()
	warning
Date: Wed, 31 Dec 2008 10:09:18 +0100
Message-ID: <1230714558.24416.1.camel@odie.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ivo van Doorn <IvDoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cs.aau.dk ([130.225.194.6]:46859 "EHLO smtp.cs.aau.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755170AbYLaKHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2008 05:07:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4dec9b807be757780ca3611a959ac22c28d292a7 ("rfkill: strip pointle=
ss
notifier chain") removed the only user of rfkill_led_trigger() that was=
 not
guarded by #ifdef CONFIG_RFKILL_LEDS. Therefore, move rfkill_led_trigge=
r()
completely inside #ifdef CONFIG_RFKILL_LEDS and avoid the compile time
warning:

net/rfkill/rfkill.c:59: warning: 'rfkill_led_trigger' defined but not u=
sed

Signed-off-by: Simon Holm Th=C3=B8gersen <odie@cs.aau.dk>
---
 net/rfkill/rfkill.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 3c94f76..3eaa394 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -54,10 +54,10 @@ static unsigned long rfkill_states_lockdflt[BITS_TO=
_LONGS(RFKILL_TYPE_MAX)];
 static bool rfkill_epo_lock_active;
=20

+#ifdef CONFIG_RFKILL_LEDS
 static void rfkill_led_trigger(struct rfkill *rfkill,
 			       enum rfkill_state state)
 {
-#ifdef CONFIG_RFKILL_LEDS
 	struct led_trigger *led =3D &rfkill->led_trigger;
=20
 	if (!led->name)
@@ -66,10 +66,8 @@ static void rfkill_led_trigger(struct rfkill *rfkill=
,
 		led_trigger_event(led, LED_OFF);
 	else
 		led_trigger_event(led, LED_FULL);
-#endif /* CONFIG_RFKILL_LEDS */
 }
=20
-#ifdef CONFIG_RFKILL_LEDS
 static void rfkill_led_trigger_activate(struct led_classdev *led)
 {
 	struct rfkill *rfkill =3D container_of(led->trigger,
--=20
1.6.0.2.526.g5c283

