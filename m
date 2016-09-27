From: Zach Brown <zach.brown@ni.com>
Subject: [RFC v2 0/4] Add support for led triggers on phy link state change
Date: Tue, 27 Sep 2016 16:51:47 -0500
Message-ID: <1475013111-18942-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, zach.brown@ni.com,
 gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net, mlindner@marvell.com
To: f.fainelli@gmail.com
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

Fix two net drivers that declared enum constants that conflict with enum
constants in linux/leds.h

Create function that encapsulates actions taken during the adjust phy link step
of phy state changes.

Add support for led triggers on phy link state changes by adding
a config option. When set the config option will create a set of led triggers
for each phy device. Users can use the led triggers to represent link state
changes on the phy.

v2:
 * New patch that creates phy_adjust_link function to encapsulate actions taken
   when adjusting phy link during phy state changes
 * led trigger speed strings changed to match existing phy speed strings
 * New function that maps speeds to led triggers
 * Replace magic constants with definitions when declaring trigger name buffer
   and number of triggers.

Josh Cartwright (1):
  phy,leds: add support for led triggers on phy link state change

Zach Brown (3):
  skge: Change LED_OFF to LED_REG_OFF in marvel skge driver to avoid
    conflicts with leds namespace
  staging: rtl8712: Change _LED_STATE enum in rtl871x driver to avoid
    conflicts with LED namespace
  phy: Encapsulate actions performed during link state changes into
    function phy_adjust_link

 drivers/net/ethernet/marvell/skge.c   |   4 +-
 drivers/net/ethernet/marvell/skge.h   |   2 +-
 drivers/net/phy/Kconfig               |  13 +-
 drivers/net/phy/Makefile              |   1 +
 drivers/net/phy/phy.c                 |  22 +-
 drivers/net/phy/phy_device.c          |   4 +
 drivers/net/phy/phy_led_triggers.c    | 121 +++++++++++
 drivers/staging/rtl8712/rtl8712_led.c | 388 +++++++++++++++++-----------------
 include/linux/phy.h                   |   9 +
 include/linux/phy_led_triggers.h      |  52 +++++
 10 files changed, 410 insertions(+), 206 deletions(-)
 create mode 100644 drivers/net/phy/phy_led_triggers.c
 create mode 100644 include/linux/phy_led_triggers.h

--
2.7.4
