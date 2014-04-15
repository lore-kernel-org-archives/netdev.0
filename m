From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 0/7] net: rfkill: gpio: Add device tree support
Date: Tue, 15 Apr 2014 14:41:34 +0800
Message-ID: <1397544101-18135-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBX5JWONAKGQELDT4LFY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi everyone,

This patch series adds device tree support to rfkill-gpio, and
fixes some issues I ran into. This is so we can define and control
RF devices through the device tree, such as the Broadcom BCM20710
UART-based Bluetooth device found on the CubieTruck.

The series is based on Heikki's rfkill-gpio cleanup patches [1],
applied on 3.15-rc1. Kudos to Heikki for paving the way.

 [1] https://lkml.org/lkml/2014/4/1/451

The device tree bindings are much better than was defined in the
RFC series I sent a few months earlier [2], due to cleanups by
Heikki, and named gpios (via gpio-names) implemented in the first
two patches. Hopefully this will satisfy everyone.

 [2] https://lkml.org/lkml/2014/1/17/31

The CubieTruck uses a non-default clock rate oscillator for the
BCM20710 device. As the datasheet states, a precise 32.768 KHz
low power clock must be provided at power on for the device to
detect the correct clock rate of the main oscillator. Hence the
need for the "clock-frequency" property.

The first 2 patches should go through the gpio tree. The 4 rfkill-gpio
patches should go through the same tree that Heikki's patches are
in. Maxime, can you take the last one?

A big thanks to everyone who gave reviews and suggestions.


Changes since RFC:

  - Dropped gpio name buffer fix patch (not needed after cleanup patches)
  - New gpios/gpio-names support for device trees
  - Simplify device tree bindings due to name cleanup and gpio-names
    support


Cheers

ChenYu

Chen-Yu Tsai (7):
  gpiolib: gpiolib-of: Implement device tree gpio-names based lookup
  gpiolib: Support purely name based gpiod lookup in device trees
  net: rfkill: gpio: use clk_prepare_enable/clk_disable_unprepare
  net: rfkill: gpio: fix reversed clock enable state
  net: rfkill: gpio: add device tree support
  net: rfkill: gpio: add clock-frequency device tree property
  ARM: sun7i: cubietruck: enable bluetooth module

 .../devicetree/bindings/rfkill/rfkill-gpio.txt     | 26 ++++++++++++
 arch/arm/boot/dts/sun7i-a20-cubietruck.dts         | 25 +++++++++++
 drivers/gpio/gpiolib-of.c                          | 48 ++++++++++++++++++++++
 drivers/gpio/gpiolib.c                             |  9 +++-
 include/linux/of_gpio.h                            |  3 ++
 net/rfkill/rfkill-gpio.c                           | 34 +++++++++++++--
 6 files changed, 140 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt

-- 
1.9.1
