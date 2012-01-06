From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 05 Jan 2012 18:08:21 -0600
Message-ID: <4F063B75.8020207@lwfinger.net>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com> <4F0635FE.6050507@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	gwingerde@gmail.com, davem@davemloft.net,
	bhutchings@solarflare.com, greg@kroah.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F0635FE.6050507@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fabio,

Does this patch fix your problem?

Larry

Index: wireless-testing-new/drivers/misc/Kconfig
===================================================================
--- wireless-testing-new.orig/drivers/misc/Kconfig
+++ wireless-testing-new/drivers/misc/Kconfig
@@ -10,6 +10,17 @@ config SENSORS_LIS3LV02D
         select INPUT_POLLDEV
         default n

+# This selection is used by several wireless devices, and placing it outside
+# the MISC_DEVICES conditional allows those drivers to be built no matter
+# the MISC_DEVICES value.
+config EEPROM_93CX6
+       tristate "EEPROM 93CX6 support"
+       help
+         This is a driver for the EEPROM chipsets 93c46 and 93c66.
+         The driver supports both read as well as write commands.
+
+         If unsure, say N.
+
  menuconfig MISC_DEVICES
         bool "Misc devices"
         ---help---
Index: wireless-testing-new/drivers/misc/eeprom/Kconfig
===================================================================
--- wireless-testing-new.orig/drivers/misc/eeprom/Kconfig
+++ wireless-testing-new/drivers/misc/eeprom/Kconfig
@@ -62,14 +62,6 @@ config EEPROM_MAX6875
           will be called max6875.


-config EEPROM_93CX6
-       tristate "EEPROM 93CX6 support"
-       help
-         This is a driver for the EEPROM chipsets 93c46 and 93c66.
-         The driver supports both read as well as write commands.
-
-         If unsure, say N.
-
  config EEPROM_93XX46
         tristate "Microwire EEPROM 93XX46 support"
         depends on SPI && SYSFS
