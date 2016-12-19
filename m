From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net 0/3] Fix integration of eee-broken-modes
Date: Mon, 19 Dec 2016 16:05:35 +0100
Message-ID: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Neil Armstrong <narmstrong@baylibre.com>,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 Kevin Hilman <khilman@baylibre.com>, linux-kernel@vger.kernel.org,
 Yegor Yefremov <yegorslists@googlemail.com>,
 Julia Lawall <julia.lawall@lip6.fr>, Andre Roth <neolynx@gmail.com>,
 Carlo Caione <carlo@caione.org>, linux-amlogic@lists.infradead.org,
 =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
 linux-arm-kernel@lists.infradead.org, Jerome Brunet <jbrunet@baylibre.com>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The purpose of this series is to fix the integration of the ethernet phy
property "eee-broken-modes" [0]

The v3 of this series has been merged, missing a fix (error reported by
kbuild robot) available in the v4 [1]

More importantly, Florian opposed adding a DT property mapping a device
register this directly [2]. The concern was that the property could be
abused to implement platform configuration policy. After discussing it,
I think we agreed that such information about the HW (defect) should appear
in the platform DT. However, the preferred way is to add a boolean property
for each EEE broken mode.

[0]: http://lkml.kernel.org/r/1480326409-25419-1-git-send-email-jbrunet@baylibre.com
[1]: http://lkml.kernel.org/r/1480348229-25672-1-git-send-email-jbrunet@baylibre.com
[2]: http://lkml.kernel.org/r/e14a3b0c-dc34-be14-48b3-518a0ad0c080@gmail.com

Jerome Brunet (3):
  net: phy: fix sign type error in genphy_config_eee_advert
  net: phy: use boolean dt properties for eee broken modes
  dt: bindings: net: use boolean dt properties for eee broken modes

 Documentation/devicetree/bindings/net/phy.txt | 10 ++++++++--
 drivers/net/phy/phy_device.c                  | 22 +++++++++++++++++-----
 include/dt-bindings/net/mdio.h                | 19 -------------------
 3 files changed, 25 insertions(+), 26 deletions(-)
 delete mode 100644 include/dt-bindings/net/mdio.h

-- 
2.7.4
