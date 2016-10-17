From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH v5 0/4] Add support for led triggers on phy link state change
Date: Mon, 17 Oct 2016 10:49:51 -0500
Message-ID: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 andrew@lunn.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 rpurdie@rpsys.net, gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net,
 j.anaszewski@samsung.com, linux-leds@vger.kernel.org, mlindner@marvell.com
To: <f.fainelli@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Fix skge driver that declared enum contants that conflicted with enum
constants in linux/leds.h

Create function that encapsulates actions taken during the adjust phy link step
of phy state changes.

Create function that provides list of speeds currently supported by the phy.

Add support for led triggers on phy link state changes by adding
a config option. When set the config option will create a set of led triggers
for each phy device. Users can use the led triggers to represent link state
changes on the phy.

v2:
 * New patch that creates phy_adjust_link function to encapsulate actions taken
   when adjusting phy link during phy state changes
 * led trigger speed strings changed to match existing phy speed strings
 * New function that maps speeds to led triggers
 * Replace magic constants with definitions when declaring trigger name
   buffer and number of triggers.
v3:
 * Changed LED_ON to LED_REG_ON in skge driver to avoid possible future
   conflict and improve consistency.
 * Dropped rtl8712 patch that was accepted separately.
v4:
 * tweaked commit message
v5
 * Changed commit message to explain relationship between the new triggers and
   leds driven by phys.
 * Added new patch that creates phy_supported_speeds function.
 * Moved phy_leds_triggers_register and phy_leds_triggers_unregister to
   phy_attach and phy_detach respectively. This change is so the
   phydev->supported field will be filled by the time the triggers are
   registered.
 * Changed hardcoded list of triggers to dynamic list determined by speeds
   return by phy_supported_speeds.

Zach Brown (4):
  skge: Rename LED_OFF and LED_ON in marvel skge driver to avoid
    conflicts with     leds namespace
  net: phy: Encapsulate actions performed during link state changes into
        function phy_adjust_link
  net: phy: Create phy_supported_speeds function which lists speeds
    currently supported by a     phydevice
  net: phy: leds: add support for led triggers on phy link state change

 drivers/net/ethernet/marvell/skge.c |   6 +-
 drivers/net/ethernet/marvell/skge.h |   4 +-
 drivers/net/phy/Kconfig             |  13 ++++
 drivers/net/phy/Makefile            |   1 +
 drivers/net/phy/phy.c               |  57 ++++++++++++---
 drivers/net/phy/phy_device.c        |   5 ++
 drivers/net/phy/phy_led_triggers.c  | 136 ++++++++++++++++++++++++++++++++++++
 include/linux/phy.h                 |  22 ++++++
 include/linux/phy_led_triggers.h    |  51 ++++++++++++++
 9 files changed, 282 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/phy/phy_led_triggers.c
 create mode 100644 include/linux/phy_led_triggers.h

-- 
2.7.4
