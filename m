From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [00/22] Cyclades PC300 driver: summary of patch series
Date: Sun, 29 Jan 2012 18:42:43 -0800
Message-ID: <20120130024243.GA10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Cyclades PC-300 is a line of PCI synchronous serial cards, which was
produced in single and dual port models with either T1/E1 or V.35 ports.
It used a Hitachi HD64572 (SCA-II) synchronous serial chip, and in the
T1/E1 models an Infineon FALC-LH line interface/framing chip.  Copies
of the hardware documentation may be found at [1].

There is a driver in the current kernel source tree based on version 3.4.5
of the original (GPLed) Cyclades driver; it has been disabled as broken
for years due to having never been updated for various HDLC-related
changes.  The last released driver from Cyclades was 4.1.0, and it may
be obtained from [2].

As I mentioned, this driver is rather old and does not build with the current
kernel for several reasons, and it never worked on anything other than 32-bit
x86 machines.  I originally began working with this driver to get it running
on a sparc64 architecture, and have been using my own version based on the
Cyclades 4.1.0 release ever since, which I now submit for integration into
the kernel tree.

There are 20 patches to follow in this series, one which merges version 4.1.0
of the driver in, and 19 which update it to work with current kernel
interfaces and fix various bugs and stylistic problems.  Additionally, for
convenience I have included two omnibus patches combining patches 01 through
16 and 01 through 20 of the series, respectively.  A summary list of patches
follows:

 * Patches 01 through 16 merge in version 4.1.0, and fix build, portability
   and style problems.  As of patch 16, the driver will build cleanly and
   will detect hardware, but not operate reliably.

[01/22] Merge in Cyclades driver version 4.1.0

         - This patch contains many style violations; for the sake of
           organization they are all fixed in patch 16.

[02/22] Re-enable Kconfig option
[03/22] Fix usage of types

         - As with patch 01, this patch contains style violations detected
           by checkpatch.pl due to edits on lines containing exist style
           problems.  They are fixed in patch 16.

[04/22] Fix prototypes

         - As with patches 01 and 03

[05/22] Update to use new HDLC interface

         - As with patches 01, 03 and 04

[06/22] Use skb_copy_to_linear_data() and skb_reset_mac_header()
[07/22] ioctl() fixes for mixed 64/32-bit systems

         - This patch modifies a structure passed in an ioctl() for
           portability, and thus requires an updated set of user-space
           tools which may be obtained from [3].  For reference the
           original Cyclades userland I modified is included in the driver
           tarball [2].

[08/22] Use DEFINE_PCI_DEVICE_TABLE
[09/22] Use kzalloc() so we don't have to memset()
[10/22] Fix interrupt handling and use IRQF_SHARED rather than SA_SHIRQ
[11/22] Improve printk()s for debugging and portability
[12/22] Locking improvements
[13/22] Alignment fix for portability
[14/22] Use struct work_struct in tty driver
[15/22] Use struct tty_operations in tty driver
[16/22] Cleanup patch

 * Patches 17 through 19 fix bugs in the driver and are necessary for reliable
   and efficient operation.

[17/22] Queue stop/start fix
[18/22] Adjust SCA-II DMA buffer parameters
[19/22] Improve DCD change detection

 * Patch 20 updates the version history in pc300_drv.c to refer to this patch
   series

[20/22] Add version history for this patch series

 * Patches 21 and 22 are omnibus patches combining patches 01 through 16 and
   01 through 20 respectively, to allow easy verification that all style
   problems introduced in patches 01, 03, 04 and 05 are fixed later.

[21/22] Omnibus patch from merge up to cleanup (patches 01 through 16 inclusive)
[22/22] Omnibus patch from merge up to final version (patches 01 through 20 inclusive)

These patches are all relative to kernel 3.3-rc1.  Please Cc: replies to
andrea@persephoneslair.org.

[1] http://charon.persephoneslair.org/~andrea/pc300/pc300-docs.tar.bz2
[2] ftp://ftp.cyclades.com/pub/cyclades/pc300/linux/pc300-4.1.0.tar.gz
[3] http://charon.persephoneslair.org/~andrea/software/pc300utils/pc300utils-4.1.1.tar.bz2

-- 
Andrea Shepard
