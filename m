From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] move sb1250-mac's probe function to .devinit.text
Date: Tue, 21 Jul 2009 23:25:25 +0200
Message-ID: <1248211527-32253-4-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiwei Wang <weiwei.wang@windriver.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53221 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476AbZGUVZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 17:25:42 -0400
In-Reply-To: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pointer to sbmac_probe is passed to the core via
platform_driver_register and so the function must not disappear when th=
e
=2Einit sections are discarded.  Otherwise (if also having HOTPLUG=3Dy)
unbinding and binding a device to the driver via sysfs will result in a=
n
oops as does a device being registered late.

An alternative to this patch is using platform_driver_probe instead of
platform_driver_register plus removing the pointer to the probe functio=
n
from the struct platform_driver.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Weiwei Wang <weiwei.wang@windriver.com>
Cc: Jeff Garzik <jgarzik@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Maciej W. Rozycki <macro@linux-mips.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: netdev@vger.kernel.org

---
 drivers/net/sb1250-mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index d8c9cf1..96b37b9 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2688,7 +2688,7 @@ static int sbmac_poll(struct napi_struct *napi, i=
nt budget)
 }
=20
=20
-static int __init sbmac_probe(struct platform_device *pldev)
+static int __devinit sbmac_probe(struct platform_device *pldev)
 {
 	struct net_device *dev;
 	struct sbmac_softc *sc;
--=20
tg: (aea1f79..) t/platsection/sbmac_driver (depends on: linus/master)
