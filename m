From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 9/9] net: move am79c961's probe function to .devinit.text
Date: Thu,  4 Feb 2010 20:56:57 +0100
Message-ID: <1265313417-5568-9-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20100203150850.GA28815@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roel Kluin <12o3l@tiscali.nl>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100203150850.GA28815@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Roel Kluin <12o3l@tiscali.nl>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Hello,

@David Miller: this patch is in patchwork with State: Not Applicable.
Does that mean that netdev isn't the right tree for this patch?

Best regards
Uwe

 drivers/net/arm/am79c961a.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 164b37e..1c3c1f9 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -680,7 +680,7 @@ static const struct net_device_ops am79c961_netdev_=
ops =3D {
 #endif
 };
=20
-static int __init am79c961_probe(struct platform_device *pdev)
+static int __devinit am79c961_probe(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct net_device *dev;
--=20
1.6.6
