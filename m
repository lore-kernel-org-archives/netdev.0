From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [RFC PATCH v8 0/7] PCI: rockchip: Move PCIe WAKE# handling into pci core
Date: Thu, 26 Oct 2017 21:28:33 +0800
Message-ID: <20171026132840.20946-1-jeffy.chen@rock-chips.com>
Cc: linux-pm@vger.kernel.org, tony@atomide.com,
        shawn.lin@rock-chips.com, briannorris@chromium.org,
        rjw@rjwysocki.net, dianders@chromium.org,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Xinming Hu <huxm@marvell.com>, linux-wireless@vger.kernel.org,
        linux-pci@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Heiko Stuebner <heiko@sntech.de>, linux-acpi@vger.kernel.org,
        linux-rockchip@lists.infradead.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Will Deacon <will.deacon@arm.com>,
        Matthias Kaehlcke <mka@chromium.org>,
        devicetree@vger.kernel.org, Ganapathi Bhat <gbhat@marvell.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Len Brown <lenb@kernel.org>,
        linux-arm-kernel@lists.infradead.org, netd
To: linux-kernel@vger.kernel.org, bhelgaas@google.com
Return-path: <linux-pm-owner@vger.kernel.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently we are handling wake irq in mrvl wifi driver. Move it into
pci core.

Tested on my chromebook bob(with cros 4.4 kernel and mrvl wifi).


Changes in v8:
Add optional "pci", and rewrite commit message.
Rewrite the commit message.
Add pci-of.c and use platform_pm_ops to handle the PCIe WAKE# signal.

Changes in v7:
Move PCIE_WAKE handling into pci core.

Changes in v6:
Fix device_init_wake error handling, and add some comments.

Changes in v5:
Move to pci.txt
Use "wakeup" instead of "wake"
Rebase.

Changes in v3:
Fix error handling.

Changes in v2:
Use dev_pm_set_dedicated_wake_irq.

Jeffy Chen (7):
  dt-bindings: PCI: Add definition of PCIe WAKE# irq and PCI irq
  mwifiex: Disable wakeup irq handling for pcie
  arm64: dts: rockchip: Handle PCIe WAKE# signal in pcie driver for Gru
  of/irq: Adjust of pci irq parsing for multiple interrupts
  PCI: Make pci_platform_pm_ops's callbacks optional
  PCI / PM: Move acpi wakeup code to pci core
  PCI / PM: Add support for the PCIe WAKE# signal for OF

 Documentation/devicetree/bindings/pci/pci.txt |   3 +
 arch/arm64/boot/dts/rockchip/rk3399-gru.dtsi  |  15 +--
 drivers/net/wireless/marvell/mwifiex/main.c   |   4 +
 drivers/of/of_pci_irq.c                       |  13 ++-
 drivers/pci/Makefile                          |   2 +-
 drivers/pci/pci-acpi.c                        | 121 +++++++++++------------
 drivers/pci/pci-driver.c                      |   9 ++
 drivers/pci/pci-of.c                          | 136 ++++++++++++++++++++++++++
 drivers/pci/pci.c                             | 112 +++++++++++++++++----
 drivers/pci/pci.h                             |  31 ++++--
 drivers/pci/probe.c                           |  12 ++-
 drivers/pci/remove.c                          |   2 +
 include/linux/pci.h                           |   2 +
 13 files changed, 365 insertions(+), 97 deletions(-)
 create mode 100644 drivers/pci/pci-of.c

-- 
2.11.0
