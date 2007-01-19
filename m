From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.20-rc5: known regressions with patches (v2)
Date: Fri, 19 Jan 2007 12:43:26 +1100
Message-ID: <1169171008.21196.34.camel@shinybook.infradead.org>
References: <Pine.LNX.4.64.0701121424520.11200@woody.osdl.org>
	 <20070118195915.GC9093@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Michael Gernoth <gernoth@informatik.uni-erlangen.de>,
	Daniel Drake <dsd@gentoo.org>,
	David L Stevens <dlstevens@us.ibm.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Dave Jones <davej@redhat.com>, len.brown@intel.com,
	linux-acpi@vger.kernel.org, cpufreq@lists.linux.org.uk,
	Russell King <rmk+lkml@arm.linux.org.uk>,
	Al Viro <viro@zeniv.linux.org.uk>, jffs-dev@axis.com,
	Miles Lane <miles.lane@gmail.com>, avi@qumranet.com,
	kvm-devel@lists.sourceforge.net, Roland Dreier <rdreier@cisco.com>,
	greg@kroah.com, linux-usb-devel@lists.sourceforge.net
Return-path: <linux-acpi-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20070118195915.GC9093@stusta.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-18 at 20:59 +0100, Adrian Bunk wrote:
> Subject    : CONFIG_JFFS2_FS_DEBUG=3D2 compile error
> References : http://lkml.org/lkml/2007/1/12/161
> Submitter  : Russell King <rmk+lkml@arm.linux.org.uk>
> Caused-By  : Al Viro <viro@zeniv.linux.org.uk>
>              commit 914e26379decf1fd984b22e51fd2e4209b7a7f1b
> Handled-By : David Woodhouse <dwmw2@infradead.org>
> Status     : patch available

Linus, please pull from git://git.infradead.org/mtd-2.6.git

This fixes the above bug along with a few others. It does also contain =
a
small amount of new code which has been waiting for a while (including
the driver for the CAF=C3=89 NAND controller which we use on OLPC.).

My apologies for missing the merge window and first asking you to pull
this a few hours after 2.6.20-rc1 was cut; I'd been waiting for the
bitrev stuff to land, and had waited too long.

Adrian Bunk (3):
      [MTD] SSFDC must depend on BLOCK
      [MTD] [NAND] rtc_from4.c: use lib/bitrev.c
      [MTD] make drivers/mtd/cmdlinepart.c:mtdpart_setup() static

Adrian Hunter (2):
      [MTD] OneNAND: Implement read-while-load
      [MTD] OneNAND: Handle DDP chip boundary during read-while-load

Akinobu Mita (1):
      [JFFS2] Use rb_first() and rb_last() cleanup

Alan Cox (1):
      [MTD] MAPS: esb2rom: use hotplug safe interfaces

Alexey Dobriyan (1):
      [MTD] JEDEC probe: fix comment typo (devic)

Amit Choudhary (1):
      [JFFS2] Fix error-path leak in summary scan

Andrew Morton (1):
      [MTD] Tidy bitrev usage in rtc_from4.c

Andrew Victor (2):
      [MTD] NAND: AT91 NAND driver
      [MTD] NAND: Support for 16-bit bus-width on AT91.

Artem Bityutskiy (10):
      [MTD] core: trivial comments fix
      [MTD] NAND: nandsim: support subpage write
      [MTD] increase MAX_MTD_DEVICES
      [MTD] add get_mtd_device_nm() function
      [MTD] add get and put methods
      [MTD] return error code from get_mtd_device()
      [MTD] nandsim: bugfix in page addressing
      [JFFS2] add cond_resched() when garbage collecting deletion diren=
t
      [JFFS2] Reschedule in loops
      [MTD] OneNAND: release CPU in cycles

Burman Yan (1):
      [MTD] replace kmalloc+memset with kzalloc

Dave Olsen (1):
      [MTD] [MAPS] Support for BIOS flash chips on the nvidia ck804 sou=
thbridge

David Anders (1):
      [MTD] NOR: leave Intel chips in read-array mode on suspend

David Woodhouse (29):
      [MTD NAND] Initial import of CAF=C3=89 NAND driver.
      [MTD NAND] OLPC CAF=C3=89 driver update
      Merge branch 'master' of git://git.kernel.org/.../torvalds/linux-=
2.6
      [MTD] NAND: Combined oob buffer so it's contiguous with data
      [MTD] NAND: Correct setting of chip->oob_poi OOB buffer
      Merge git://git.infradead.org/~dwmw2/cafe-2.6
      [MTD] NAND: Add hardware ECC correction support to CAF=C3=89 NAND=
 driver
      [MTD] NAND: CAF=C3=89 NAND driver cleanup, fix ECC on reading emp=
ty flash
      [MTD] NAND: Disable ECC checking on CAF=C3=89 since it's broken f=
or now
      [MTD] NAND: Caf=C3=A9 ECC -- remove spurious BUG_ON() in err_pos(=
)
      [MTD] NAND: Reset Caf=C3=A9 controller before initialising.
      [MTD] CAF=C3=89 NAND: Add 'slowtiming' parameter, default usedma =
and checkecc on
      [MTD] NAND: Add ECC debugging for CAF=C3=89
      [MTD] NAND: Remove empty block ECC workaround
      [MTD] NAND: Fix timing calculation in CAF=C3=89 debugging message
      [MTD] NAND: Use register #defines throughout CAF=C3=89 driver, no=
t numbers
      [MTD] NAND: Add register debugging spew option to CAF=C3=89 drive=
r
      [MTD] NAND: Fix ECC settings in CAF=C3=89 controller driver.
      Merge git://git.infradead.org/~dwmw2/cafe-2.6
      Merge git://git.infradead.org/~kmpark/onenand-mtd-2.6
      [MTD] [NAND] Update CAF=C3=89 driver interrupt handler prototype
      [MTD] Use EXPORT_SYMBOL_GPL() for exported symbols.
      [MTD] Remove trailing whitespace
      Merge branch 'master' of git://git.kernel.org/.../torvalds/linux-=
2.6
      [MTD] Fix SSFDC build for variable blocksize.
      [MTD] Fix ssfdc blksize typo
      Merge branch 'master' of git://git.infradead.org/~kmpark/onenand-=
mtd-2.6
      [JFFS2] debug.h: include <linux/sched.h> for current->pid
      Merge branch 'master' of git://git.kernel.org/.../torvalds/linux-=
2.6

Haavard Skinnemoen (1):
      [MTD] bugfix: DataFlash is not bit writable

Jeff Garzik (1):
      [JFFS2] kill warning RE debug-only variables

Josh Boyer (1):
      [MTD] add MTD_BLKDEVS Kconfig option

Kyungmin Park (9):
      MTD: OneNAND: interrupt based wait support
      [MTD] OneNAND: lock support
      [MTD] OneNAND: Single bit error detection
      [MTD] OneNAND: fix oob handling in recent oob patch
      [JFFS2] use the ref_offset macro
      [MTD] OneNAND: fix onenand_wait bug
      [MTD] OneNAND: add subpage write support
      [MTD] OneNAND: fix onenand_wait bug in read ecc error
      [MTD] OneNAND: return ecc error code only when 2-bit ecc occurs

Lew Glendenning (1):
      [MTD] MAPS: Support for BIOS flash chips on Intel ESB2 southbridg=
e

Mariusz Kozlowski (1):
      [MTD] [NAND] Compile fix in rfc_from4.c

Qi Yong (1):
      [JFFS2] Fix jffs2_follow_link() typo

Ralf Baechle (1):
      [MTD] Nuke IVR leftovers

Randy Dunlap (2):
      [MTD] Fix printk format warning in physmap. (resources again)
      [MTD] ESB2ROM uses PCI

Ricard Wanderl=C3=B6f (2):
      [MTD] mtdchar: Fix MEMGETOOBSEL and ECCGETLAYOUT ioctls
      [MTD] NAND: Fix nand_default_mark_blockbad() when flash-based BBT=
 disabled

Richard Purdie (1):
      [MTD] Allow variable block sizes in mtd_blkdevs

Rod Whitby (1):
      [MTD] Support combined RedBoot FIS directory and configuration ar=
ea

Ryan Jackson (2):
      [MTD] MAPS: Add parameter to amd76xrom to override rom window siz=
e
      [MTD] CHIPS: Support for SST 49LF040B flash chip

Stefan Roese (1):
      [MTD] [NAND] Fix endianess bug in ndfc.c

Thomas Gleixner (1):
      [MTD] NAND: add subpage write support

Timo Lindhorst (2):
      [MTD] [NAND] fix ifdef option in nand_ecc.c
      [MTD] NAND: use SmartMedia ECC byte order for ndfc

Vijay Kumar (3):
      [MTD] NAND: nandsim page-wise allocation (1/2)
      [MTD] NAND: nandsim page-wise allocation (2/2)
      [MTD] NAND: nandsim coding style fix

Vitaly Wool (2):
      [MTD] [NAND] remove len/ooblen confusion.
      [MTD] of_device-based physmap driver

Yan Burman (1):
      [JFFS2] replace kmalloc+memset with kzalloc

Yoichi Yuasa (2):
      [MTD] MAPS: Remove ITE 8172G and Globespan IVR MTD support
      [MTD] fix map probe name for cstm_mips_ixx

Yoshinori Sato (1):
      [MTD] redboot partition combined fis / config problem


--=20
dwmw2

-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
