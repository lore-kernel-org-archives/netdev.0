From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/16] ARM: mostly harmless gcc warnings
Date: Fri,  5 Oct 2012 16:55:14 +0200
Message-ID: <1349448930-23976-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
 Dave Martin <dave.martin@linaro.org>, Jan Kara <jack@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, linux-fbdev@vger.kernel.org,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Grant Likely <grant.likely@secretlab.ca>, Pavel Machek <pavel@suse.cz>,
 netdev@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>,
 Christoph Lameter <cl@linux.com>, Kukjin Kim <kgene.kim@samsung.com>,
 Mike Turquette <mturquette@linaro.org>, Wan ZongShun <mcuos.com@gmail.com>,
 linux-scsi@vger.kernel.org,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 Jochen Friedrich <jochen@scram.de>, linux-samsung-soc@vger.kernel.org,
 Julian Anastasov <ja@ssi.bg>, arm@kernel.org,
 Alan Stern <stern@rowland.harvard.edu>, Mike Rapoport <mike@compulab.co.il>,
 Russell King <rmk+kernel@arm.linux.org.uk>, coreteam@netfilter.org,
 Arnd Bergmann <arnd@arndb.de>, linux-p
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

In my attempt to weed out all warnings in ARM defconfigs, this
is the latest installment of patches. Ideally these could all
go through the respective subsystem maintainer trees, but
for any patches I don't hear anything back on, I will just
merge them through the arm-soc tree.

	Arnd

Arnd Bergmann (16):
  ARM: warnings in arch/arm/include/asm/uaccess.h
  ARM: binfmt_flat: unused variable 'persistent'
  SCSI: ARM: ncr5380/oak uses no interrupts
  SCSI: ARM: make fas216_dumpinfo function conditional
  vfs: bogus warnings in fs/namei.c
  mm/slob: use min_t() to compare ARCH_SLAB_MINALIGN
  cgroup: fix warning when building without any subsys
  ipvs: fix ip_vs_set_timeout debug messages
  USB: EHCI: mark ehci_orion_conf_mbus_windows __devinit
  clk: don't mark clkdev_add_table as init
  pcmcia: sharpsl: don't discard sharpsl_pcmcia_ops
  video: mark nuc900fb_map_video_memory as __devinit
  ARM: be really quiet when building with 'make -s'
  ARM: pxa: armcore: fix PCI PIO warnings
  spi/s3c64xx: use correct dma_transfer_direction type
  ARM: pass -marm to gcc by default for both C and assembler

 arch/arm/Makefile               |   13 +++++++------
 arch/arm/boot/Makefile          |   10 +++++-----
 arch/arm/common/it8152.c        |   12 +++++++++---
 arch/arm/include/asm/flat.h     |    2 +-
 arch/arm/include/asm/uaccess.h  |    4 ++--
 arch/arm/tools/Makefile         |    2 +-
 drivers/clk/clkdev.c            |    2 +-
 drivers/pcmcia/pxa2xx_sharpsl.c |    2 +-
 drivers/scsi/arm/fas216.c       |    2 +-
 drivers/scsi/arm/oak.c          |    1 +
 drivers/spi/spi-s3c64xx.c       |    2 +-
 drivers/usb/host/ehci-orion.c   |    2 +-
 drivers/video/nuc900fb.c        |    2 +-
 fs/namei.c                      |    6 +++---
 include/linux/cgroup.h          |    2 +-
 mm/slob.c                       |    6 +++---
 net/netfilter/ipvs/ip_vs_ctl.c  |   10 ++++++----
 17 files changed, 45 insertions(+), 35 deletions(-)

Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Ben Blum <bblum@andrew.cmu.edu>
Cc: Ben Dooks <ben-linux@fluff.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Bryan Wu <bryan.wu@canonical.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Dave Martin <dave.martin@linaro.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Greg Ungerer <gerg@uclinux.org>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: Igor Grinberg <grinberg@compulab.co.il>
Cc: Jan Kara <jack@suse.cz>
Cc: Jochen Friedrich <jochen@scram.de>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Cc: Kukjin Kim <kgene.kim@samsung.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Michal Marek <mmarek@suse.cz>
Cc: Mike Rapoport <mike@compulab.co.il>
Cc: Mike Turquette <mturquette@linaro.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Pavel Machek <pavel@suse.cz>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Simon Horman <horms@verge.net.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: Wan ZongShun <mcuos.com@gmail.com>
Cc: coreteam@netfilter.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-fbdev@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-pcmcia@lists.infradead.org
Cc: linux-samsung-soc@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: netfilter@vger.kernel.org
Cc: spi-devel-general@lists.sourceforge.net


-- 
1.7.10
