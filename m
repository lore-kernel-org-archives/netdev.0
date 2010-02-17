From: <gregkh@suse.de>
Subject: patch net-move-am79c961-s-probe-function-to-.devinit.text.patch added to gregkh-2.6 tree
Date: Wed, 17 Feb 2010 13:15:00 -0800
Message-ID: <12664413002764@kroah.org>
References: <1265313417-5568-9-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: u.kleine-koenig@pengutronix.de, 12o3l@tiscali.nl,
	akpm@linux-foundation.org, gregkh@suse.de, netdev@vger.kernel.org,
	rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:50753 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756496Ab0BQVPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 16:15:18 -0500
In-Reply-To: <1265313417-5568-9-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: net: move am79c961's probe function to .devinit.text

to my gregkh-2.6 tree.  Its filename is

    net-move-am79c961-s-probe-function-to-.devinit.text.patch

This tree can be found at=20
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/pat=
ches/


=46rom u.kleine-koenig@pengutronix.de  Wed Feb 17 12:45:57 2010
=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  4 Feb 2010 20:56:57 +0100
Subject: net: move am79c961's probe function to .devinit.text
To: Greg KH <gregkh@suse.de>
Cc: Roel Kluin <12o3l@tiscali.nl>, Russell King <rmk+kernel@arm.linux.o=
rg.uk>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.or=
g>
Message-ID: <1265313417-5568-9-git-send-email-u.kleine-koenig@pengutron=
ix.de>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

A pointer to am79c961_probe is passed to the core via
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

Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Cc: Roel Kluin <12o3l@tiscali.nl>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: <netdev@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/arm/am79c961a.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -680,7 +680,7 @@ static const struct net_device_ops am79c
 #endif
 };
=20
-static int __init am79c961_probe(struct platform_device *pdev)
+static int __devinit am79c961_probe(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct net_device *dev;

