From: Ingo Molnar <mingo@elte.hu>
Subject: iwlwifi: fix build bug in "iwlwifi: fix LED stall"
Date: Mon, 21 Jul 2008 10:36:54 +0200
Message-ID: <20080721083654.GA19849@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tomas Winkler <tomas.winkler@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:32894 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753979AbYGUIhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 04:37:11 -0400
Content-Disposition: inline
In-Reply-To: <20080720.104411.81744468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hi David,

>       iwlwifi: fix LED stall

please find a small build fix below.

	Ingo

-------------->
commit c61b0199e779caf2dcfdb6e83439c1fdf9f20209
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Jul 21 10:33:42 2008 +0200

    iwlwifi: fix build bug in "iwlwifi: fix LED stall"
   =20
    -tip testing found the following build failure:
   =20
      drivers/net/wireless/iwlwifi/iwl-led.c: In function =E2=80=98iwl_=
led_brightness_set=E2=80=99:
      drivers/net/wireless/iwlwifi/iwl-led.c:198: error: =E2=80=98led_t=
ype_str=E2=80=99 undeclared (first use in this function)
      drivers/net/wireless/iwlwifi/iwl-led.c:198: error: (Each undeclar=
ed identifier is reported only once
      drivers/net/wireless/iwlwifi/iwl-led.c:198: error: for each funct=
ion it appears in.)
   =20
    Triggered if this driver is built with !CONFIG_IWLWIFI_DEBUG. Intro=
duced
    by commit 0eee61273.
   =20
    The best fix is to make led_type_str available as a zero-size symbo=
l and to
    only add members to the array if CONFIG_IWLWIFI_DEBUG is set. This =
way
    there's no overhead in the debugging case and we have type checking=
 in the
    IWL_DEBUG_LED() macro as well.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/wireless/iwlwifi/iwl-led.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-led.c b/drivers/net/wirel=
ess/iwlwifi/iwl-led.c
index 899d7a2..d7129f7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-led.c
+++ b/drivers/net/wireless/iwlwifi/iwl-led.c
@@ -44,15 +44,15 @@
 #include "iwl-io.h"
 #include "iwl-helpers.h"
=20
-#ifdef CONFIG_IWLWIFI_DEBUG
 static const char *led_type_str[] =3D {
+#ifdef CONFIG_IWLWIFI_DEBUG
 	__stringify(IWL_LED_TRG_TX),
 	__stringify(IWL_LED_TRG_RX),
 	__stringify(IWL_LED_TRG_ASSOC),
 	__stringify(IWL_LED_TRG_RADIO),
 	NULL
-};
 #endif /* CONFIG_IWLWIFI_DEBUG */
+};
=20
=20
 static const struct {
