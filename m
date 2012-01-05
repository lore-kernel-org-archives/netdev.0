From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 5 Jan 2012 17:02:46 -0200
Message-ID: <CAOMZO5DTDpp8+9FOjPXGFQtQPg7Pv5qfAwFO3UC6AUdEDgpHYg@mail.gmail.com>
References: <1325770673-17309-1-git-send-email-festevam@gmail.com>
	<4F05CBA9.1070602@lwfinger.net>
	<20120105.122004.1170447281304011158.davem@davemloft.net>
	<CAOMZO5AuZ_MHW3C1uNK7PyRz=XRHXhn2pvKCwk7iXLDd0YkDOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry.Finger@lwfinger.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, gwingerde@gmail.com,
	linville@tuxdriver.com, fabio.estevam@freescale.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61843 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab2AETCs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:02:48 -0500
In-Reply-To: <CAOMZO5AuZ_MHW3C1uNK7PyRz=XRHXhn2pvKCwk7iXLDd0YkDOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 5, 2012 at 4:06 PM, Fabio Estevam <festevam@gmail.com> wrot=
e:

> I have tried selecting MISC_DEVICES in the Kconfig's, but the warning=
 remains.
>
> I agree with Ben's comment: "That seems like a bug, since MISC_DEVICE=
S
> doesn't by itself select any
> code. =C2=A0(It's also not a meaningful category and maybe ought not =
to be an
> option at all.)"

What about the aproach below?

drivers/misc/Kconfig |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 6a1a092..9c7a474 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -10,15 +10,8 @@ config SENSORS_LIS3LV02D
 	select INPUT_POLLDEV
 	default n

-menuconfig MISC_DEVICES
-	bool "Misc devices"
-	---help---
-	  Say Y here to get to see options for device drivers from various
-	  different categories. This option alone does not add any kernel cod=
e.
-
-	  If you say N, all options in this submenu will be skipped and disab=
led.
+menu "Misc devices"

-if MISC_DEVICES

 config AD525X_DPOT
 	tristate "Analog Devices Digital Potentiometers"
@@ -516,5 +509,4 @@ source "drivers/misc/ti-st/Kconfig"
 source "drivers/misc/lis3lv02d/Kconfig"
 source "drivers/misc/carma/Kconfig"
 source "drivers/misc/altera-stapl/Kconfig"
-
-endif # MISC_DEVICES
+endmenu
--=20

This would remove the unneeded dependency of MISC_DEVICES.

I know I need to take extra care not to break other things, but just
would like to get a feedback if this approach goes into the right
direction.

Thanks,

=46abio Estevam
