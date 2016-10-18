From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v4 0/4] add support for impedance control for TI dp83867 phy and fix 2nd ethernet on dra72 rev C evm
Date: Tue, 18 Oct 2016 16:50:16 +0530
Message-ID: <20161018112020.30273-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Tony Lindgren <tony@atomide.com>,
        Russell King <linux@armlinux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sekhar Nori <nsekhar@ti.com>,
        Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for configurable impedance control for TI dp83867
phy via devicetree. More documentation in [1].
CPSW second ethernet is not working, fix it by enabling
impedance configuration on the phy.

Verified the patch on DRA72 Rev C evm, logs at [2]. Also pushed
a branch [3] for others to test.

Changes from v3:
* Fixup change log text and no code changes.

Changes from v2:
* Fixed a typo in dts and driver.

Changes from initial version:
* As per Sekhar's comment, instead of passing impedance values,
  change to max and min impedance from DT
* Adopted phy_read_mmd_indirect() to cunnrent implementation.
* Corrected the phy delay timings to the optimal value.

[1] - http://www.ti.com/lit/ds/symlink/dp83867ir.pdf
[2] - http://pastebin.ubuntu.com/23343139/
[3] - git://git.ti.com/~mugunthanvnm/ti-linux-kernel/linux.git dp83867-v4

Mugunthan V N (4):
  net: phy: dp83867: Add documentation for optional impedance control
  net: phy: dp83867: add support for MAC impedance configuration
  ARM: dts: dra72-evm-revc: add phy impedance settings
  ARM: dts: dra72-evm-revc: fix correct phy delay

 .../devicetree/bindings/net/ti,dp83867.txt         | 12 ++++++++++
 arch/arm/boot/dts/dra72-evm-revc.dts               | 10 ++++----
 drivers/net/phy/dp83867.c                          | 28 ++++++++++++++++++++++
 3 files changed, 46 insertions(+), 4 deletions(-)

-- 
2.10.1.445.g3cdd5d1
