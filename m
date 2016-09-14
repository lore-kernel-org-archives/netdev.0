From: Zach Brown <zach.brown@ni.com>
Subject: [RFC 0/3] Add support for led triggers on phy link state change
Date: Wed, 14 Sep 2016 16:55:46 -0500
Message-ID: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Larry.Finger@lwfinger.net, mlindner@marvell.com
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

Some drivers that include phy.h defined LED_OFF which conflicts with
definition in leds.h. phy led support uses leds.h so the two namespaces are no
longer isolated.
The first two patches fix the two net drivers that declared enum constants that
conflict with enum constants in linux/leds.h.

The final patch adds support for led triggers on phy link state changes by
adding a config option. When set the config option will create a set of led
triggers for each phy device. Users can use the led triggers to represent link
state changes on the phy.
The changes assumes that there are 5 speed options
10Mb,100Mb,1Gb,2.5Gb,10Gb
The assumption makes mapping a phy_device's current speed to a trigger easy,
but means there are triggers made that aren't used if the phy doesn't support
the corresponding speeds.
Thoughts on how to better manage the triggers created would be appreciated
if is important to do so.

Josh Cartwright (1):
  phy,leds: add support for led triggers on phy link state change

Zach Brown (2):
  skge: Change LED_OFF to LED_REG_OFF in marvel skge driver to avoid
    conflicts with leds namespace
  staging: rtl8712: Change _LED_STATE enum in rtl871x driver to avoid
    conflicts with LED namespace

 drivers/net/ethernet/marvell/skge.c   |   4 +-
 drivers/net/ethernet/marvell/skge.h   |   2 +-
 drivers/net/phy/Kconfig               |  12 +++
 drivers/net/phy/Makefile              |   1 +
 drivers/net/phy/phy.c                 |   8 ++
 drivers/net/phy/phy_device.c          |   4 +
 drivers/net/phy/phy_led_triggers.c    | 109 +++++++++++++++++++
 drivers/staging/rtl8712/rtl8712_led.c | 192 +++++++++++++++++-----------------
 include/linux/phy.h                   |   9 ++
 include/linux/phy_led_triggers.h      |  42 ++++++++
 10 files changed, 284 insertions(+), 99 deletions(-)
 create mode 100644 drivers/net/phy/phy_led_triggers.c
 create mode 100644 include/linux/phy_led_triggers.h

--
2.7.4
