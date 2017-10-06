From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 0/7] Modify KSZ9477 DSA driver in preparation to add other KSZ switch drivers
Date: Fri, 6 Oct 2017 13:32:58 -0700
Message-ID: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

This series of patches is to modify the original KSZ9477 DSA driver so
that other KSZ switch drivers can be added and use the common code.

There are several steps to accomplish this achievement.  First is to
rename some function names with a prefix to indicate chip specific
function.  Second is to move common code into header that can be shared.
Last is to modify tag_ksz.c so that it can handle many tail tag formats
used by different KSZ switch drivers.

ksz_common.c will contain the common code used by all KSZ switch drivers.
ksz9477.c will contain KSZ9477 code from the original ksz_common.c.
ksz9477_spi.c is renamed from ksz_spi.c.
ksz9477_reg.h is renamed from ksz_9477_reg.h.
ksz_common.h is added to provide common code access to KSZ switch
drivers.
ksz_spi.h is added to provide common SPI access functions to KSZ SPI
drivers.

v1
- Each patch in the set is self-contained
- Use ksz9477 prefix to indicate KSZ9477 specific code
- Simplify MIB counter reading code
- Switch driver code is not accessed from tag_ksz.c

Tristram Ha (7):
  Replace license with GPL.
  Clean up code according to patch check suggestions.
  Rename some functions with ksz9477 prefix to separate chip specific
    code from common code.
  Rename ksz_spi.c to ksz9477_spi.c and update Kconfig in preparation to
    add more KSZ switch drivers.
  Break KSZ9477 DSA driver into two files in preparation to add more KSZ
    switch drivers.  Add common functions in ksz_common.h so that other
    KSZ switch drivers can access code in ksz_common.c.  Add ksz_spi.h
    for common functions used by KSZ switch SPI drivers.
  Add MIB counter reading support.  Rename ksz_9477_reg.h to
    ksz9477_reg.h for consistency as the product name is always KSZ####.
    Header file ksz_priv.h no longer contains any chip specific data.
  Modify tag_ksz.c so that tail tag code can be used by other KSZ switch
    drivers.

 drivers/net/dsa/microchip/Kconfig                  |   14 +-
 drivers/net/dsa/microchip/Makefile                 |    4 +-
 drivers/net/dsa/microchip/ksz9477.c                | 1376 ++++++++++++++++++++
 .../microchip/{ksz_9477_reg.h => ksz9477_reg.h}    |   23 +-
 drivers/net/dsa/microchip/ksz9477_spi.c            |  188 +++
 drivers/net/dsa/microchip/ksz_common.c             | 1210 ++++-------------
 drivers/net/dsa/microchip/ksz_common.h             |  234 ++++
 drivers/net/dsa/microchip/ksz_priv.h               |  258 ++--
 drivers/net/dsa/microchip/ksz_spi.c                |  216 ---
 drivers/net/dsa/microchip/ksz_spi.h                |   82 ++
 include/net/dsa.h                                  |    2 +-
 net/dsa/Kconfig                                    |    4 +
 net/dsa/dsa.c                                      |    4 +-
 net/dsa/dsa_priv.h                                 |    2 +-
 net/dsa/tag_ksz.c                                  |  107 +-
 15 files changed, 2331 insertions(+), 1393 deletions(-)
 create mode 100644 drivers/net/dsa/microchip/ksz9477.c
 rename drivers/net/dsa/microchip/{ksz_9477_reg.h => ksz9477_reg.h} (98%)
 create mode 100644 drivers/net/dsa/microchip/ksz9477_spi.c
 create mode 100644 drivers/net/dsa/microchip/ksz_common.h
 delete mode 100644 drivers/net/dsa/microchip/ksz_spi.c
 create mode 100644 drivers/net/dsa/microchip/ksz_spi.h

-- 
1.9.1
