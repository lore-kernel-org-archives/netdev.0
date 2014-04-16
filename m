From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 0/3] net: mdio-gpio enhancements
Date: Tue, 15 Apr 2014 19:16:39 -0700
Message-ID: <1397614602-29694-1-git-send-email-linux@roeck-us.net>
Cc: Chris Healy <chealy@imsco-us.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series of patches adds support for active-low gpio pins
as well as for systems with separate MDI and MDO pins to the mdio-gpio
driver.

A board using those features is based on a COM Express CPU board.
The COM Express standard supports GPIO pins on its connector,
with one caveat: The pins on the connector have fixed direction
and are hard configured either as input or output pins.
The COM Express Design Guide [1] provides additional details.

The hardware uses three of the GPO/GPI pins from the COM Express board
to drive an MDIO bus. Connectivity between GPI/GPO pins and the MDIO bus
is as follows.

GPI2 --------------------+------------ MDIO
                         |
            +--------+   |
GPO2 ---+---G        |   |
        |   |        |   |
       4.7k | 2N7002 D---+
	|   |        |
	+---S        |
	|   +--------+
       GND

GPO1 --------------------------------- MDC

To support this hardware, two extensions to the driver were necessary.

- Due to the FET in the MDO path (GPO2), the MDO signal is inverted.
  The driver therefore has to support active-low GPIO pins.

- The MDIO signal must be separated into MDI and MDO.

Those changes are implemented in patch 2/3 and 3/3.
Patch 1/3 simplifies the error path and thus the subsequent
patches.


[1] http://www.picmg.org/pdf/picmg_comdg_100.pdf

----------------------------------------------------------------
Guenter Roeck (3):
      net: mdio-gpio: Use devm_ functions where possible
      net: mdio-gpio: Add support for active low gpio pins
      net: mdio-gpio: Add support for separate MDI and MDO gpio pins

 drivers/net/phy/mdio-gpio.c |   68 ++++++++++++++++++++++++++++++-------------
 include/linux/mdio-gpio.h   |    5 ++++
 2 files changed, 52 insertions(+), 21 deletions(-)
