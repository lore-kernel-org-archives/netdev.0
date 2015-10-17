From: Heiko Schocher <hs@denx.de>
Subject: [PATCH v2 0/2] net, phy, smsc: add posibility to disable energy detect mode
Date: Sat, 17 Oct 2015 06:04:34 +0200
Message-ID: <1445054676-21523-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, devicetree@vger.kernel.org,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Georg.Soffel@bosch-si.com, Tony Lindgren <tony@atomide.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some boards the energy enable detect mode leads in
trouble with some switches, so make the enabling of
this mode configurable through DT.
Therefore the property "smsc,disable-energy-detect" is
introduced.

Patch 1 introduces phy-handle support for the ti,cpsw
driver. This is needed now for the smsc phy.

Patch 2 adds the disable energy mode functionality
to the smsc phy

Changes in v2:
- add comments from Florian Fainelli
  - I did not change disable property name into enable
    because I fear to break existing behaviour
  - add smsc vendor prefix
  - remove CONFIG_OF and use __maybe_unused
  - introduce "phy-handle" ability into ti,cpsw
    driver, so I can remove bogus:
      if (!of_node && dev->parent->of_node)
          of_node = dev->parent->of_node;
    construct. Therefore new patch for the ti,cpsw
    driver is necessary.

Heiko Schocher (2):
  drivers: net: cpsw: add phy-handle parsing
  net: phy: smsc: disable energy detect mode

 Documentation/devicetree/bindings/net/cpsw.txt     |  1 +
 .../devicetree/bindings/net/smsc-lan87xx.txt       | 24 ++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c                     | 15 ++++++++++----
 drivers/net/phy/smsc.c                             | 19 ++++++++++++-----
 4 files changed, 50 insertions(+), 9 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc-lan87xx.txt

-- 
2.1.0
