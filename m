From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v5 0/2] Add support for the ethernet switch on the ESPRESSObin
Date: Thu, 19 Jan 2017 22:49:32 +0100
Message-ID: <20170119214934.27442-1-gregory.clement@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This set of patches adds support for the Marvell Ethernet switch
88E6341 which is found on the ESPRESSObin. With this series the
network is usable on this board.

>From now on, I am taking care of this series.

As Andrew Lunn pointed this switch is not fully compatible with the
6352. However it is neither fully compatible with the 6390. Actually
it is more a mix between this two families.

I created a new family for this switch and filled the ops structure by
selecting which seems the more appropriate functions. I rebased the
series on net-next/master which allowed me to benefit to the eeprom
functions introduced for the 6390.



While comparing the datasheet and the ops functions used, some
question came to me. They should not prevent applying this series,
but their answer would help me to have a better understanding of the
dsa subsystem.

- Are the temperature related operation still useful with dsa2 ?

Indeed the hwmon initialization is only done from dsa_probe which is
not called if we use dsa2.

- Why the setup is done differently between the 6390 and the 6352
  families when the have exactly the same register?

  - On the Port Controller 2, the bit PORT_CONTROL_2_MAP_DA is set for
    6352 and not for 6390 whereas the same bit exists in 6360 and the
    description for this bit is the same for both datasheet.


  - Register PORT_ATU_CONTROL and PORT_PRI_OVERRIDE are reset on 6352
    and not on 6390. While here again the registers description are
    the same.

Thanks,

Gregory


Gregory CLEMENT (1):
  net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341

Romain Perier (1):
  net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >=
    num_of_ports

 drivers/net/dsa/mv88e6xxx/chip.c      | 61 +++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 21 +++++++++++-
 2 files changed, 72 insertions(+), 10 deletions(-)

-- 
2.11.0
