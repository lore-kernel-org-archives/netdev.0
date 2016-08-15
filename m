From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [PATCH 0/9] MIPS: xilfpga: Intc and various peripherals
Date: Mon, 15 Aug 2016 14:55:26 +0100
Message-ID: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jason@lakedaemon.net>, <marc.zyngier@arm.com>,
	<Zubair.Kakakhel@imgtec.com>, <linux-mips@linux-mips.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The MIPS based Xilfpga platform uses the axi interrupt controller
daisy chained to the MIPS microAptiv cpu interrupt controller.

This patch series moves the axi interrupt controller driver out
of arch/microblaze to drivers/irqchip. This makes it usable by
MIPS.

The rest of the series basically enables drivers and adds dt nodes.

Would make sense for this to go via the MIPS tree.
Hence, ACKs from microblaze. irqchip and net welcome.

Regards,
ZubairLK

Note: Compile tested on microblaze only!

Based on v4.8-rc2

Zubair Lutfullah Kakakhel (9):
  microblaze: irqchip: Move intc driver to irqchip
  irqchip: xilinx: Add support for parent intc
  MIPS: xilfpga: Use irqchip_init instead of the legacy way
  MIPS: xilfpga: Use Xilinx AXI Interrupt Controller
  MIPS: xilfpga: Update DT node and specify uart irq
  MIPS: Xilfpga: Add DT node for AXI I2C
  net: ethernet: xilinx: Enable emaclite for MIPS
  MIPS: xilfpga: Add DT node for AXI emaclite
  MIPS: xilfpga: Update defconfig

 arch/microblaze/Kconfig                            |  1 +
 arch/microblaze/kernel/Makefile                    |  2 +-
 arch/mips/Kconfig                                  |  1 +
 arch/mips/boot/dts/xilfpga/nexys4ddr.dts           | 64 ++++++++++++++++++++++
 arch/mips/configs/xilfpga_defconfig                | 37 ++++++++++++-
 arch/mips/xilfpga/intc.c                           |  7 +--
 drivers/irqchip/Kconfig                            |  4 ++
 drivers/irqchip/Makefile                           |  1 +
 .../kernel/intc.c => drivers/irqchip/irq-xilinx.c  | 28 +++++++++-
 drivers/net/ethernet/xilinx/Kconfig                |  4 +-
 10 files changed, 139 insertions(+), 10 deletions(-)
 rename arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c (90%)

-- 
1.9.1
