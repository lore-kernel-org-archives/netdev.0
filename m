From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v3 00/11] microblaze/MIPS: xilfpga: intc and peripheral
Date: Wed, 31 Aug 2016 17:35:41 +0100
Message-ID: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <soren.brinkmann@xilinx.com>, <Zubair.Kakakhel@imgtec.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <michal.simek@xilinx.com>, <netdev@vger.kernel.org>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Hi,

The MIPS based Xilfpga platform uses the axi interrupt controller
daisy chained to the MIPS microAptiv cpu interrupt controller.
This patch series moves the axi interrupt controller driver out
of arch/microblaze to drivers/irqchip and then cleans it up a bit.
This makes it usable by MIPS. The rest of the series basically
enables drivers and adds dt nodes.

Would make sense for this to go via the MIPS tree.
Hence, ACKs from microblaze. irqchip and net welcome.

Compile tested on microblaze-el only!
Based on v4.8-rc4

Regards,
ZubairLK

V2 -> V3
Cleanup the interrupt controller driver a bit based on feedback
Rebase to v4.8-rc4

V1 -> V2
Resubmitting without truncating the diff output for file moves
Removed accidental local mac address entry
Individual logs have more detail

Zubair Lutfullah Kakakhel (11):
  microblaze: irqchip: Move intc driver to irqchip
  irqchip: axi-intc: Clean up irqdomain argument and read/write
  irqchip: axi-intc: Add support for parent intc
  MIPS: xilfpga: Use irqchip_init instead of the legacy way
  MIPS: xilfpga: Use Xilinx AXI Interrupt Controller
  MIPS: xilfpga: Update DT node and specify uart irq
  MIPS: Xilfpga: Add DT node for AXI I2C
  net: ethernet: xilinx: Generate random mac if none found
  net: ethernet: xilinx: Enable emaclite for MIPS
  MIPS: xilfpga: Add DT node for AXI emaclite
  MIPS: xilfpga: Update defconfig

 arch/microblaze/Kconfig                       |   1 +
 arch/microblaze/kernel/Makefile               |   2 +-
 arch/microblaze/kernel/intc.c                 | 196 ---------------------
 arch/mips/Kconfig                             |   1 +
 arch/mips/boot/dts/xilfpga/nexys4ddr.dts      |  63 +++++++
 arch/mips/configs/xilfpga_defconfig           |  37 +++-
 arch/mips/xilfpga/intc.c                      |   7 +-
 drivers/irqchip/Kconfig                       |   4 +
 drivers/irqchip/Makefile                      |   1 +
 drivers/irqchip/irq-axi-intc.c                | 241 ++++++++++++++++++++++++++
 drivers/net/ethernet/xilinx/Kconfig           |   4 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |   6 +-
 12 files changed, 356 insertions(+), 207 deletions(-)
 delete mode 100644 arch/microblaze/kernel/intc.c
 create mode 100644 drivers/irqchip/irq-axi-intc.c

-- 
1.9.1
