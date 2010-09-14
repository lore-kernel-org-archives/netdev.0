From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/18] Make the big kernel lock optional
Date: Tue, 14 Sep 2010 21:34:51 +0200
Message-ID: <1284492909-7147-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>,
	linux-pci@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>,
	Bob Picco <bob.picco@hp.com>, Jaroslav Kysela <perex@perex.cz>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Mark Gross <mark.gross@intel.com>, Helge Deller <deller@gmx.de>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Matt Turner <mattst88@gmail.com>, linux-media@vger.kernel.org,
	user-mode-linux-devel@lists.sourceforge.net,
	linux-s390@vger.kernel.org, Clemens Ladisch <clemens@ladisch.de>,
	Jeff Dike <jdike@addtoit.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Mikael Starvik <starvik@axis.com>, Tejun Heo <tj@kernel.org>,
	linux-m68k@lists.linux-m68k.org,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Thomas Gl
To: arnd@arndb.de
Return-path: <user-mode-linux-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel>,
	<mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=user-mode-linux-devel>
List-Post: <mailto:user-mode-linux-devel@lists.sourceforge.net>
List-Help: <mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel>,
	<mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: user-mode-linux-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a set of simple patches to remove the big kernel
lock in some remaining areas and introduce a Kconfig
option which I'd like to have included in linux-next
and get included in the 2.6.37 merge window.

I have a total of five topic branches, which together
remove the BKL from all code except those modules
which get marked as 'depends on BKL' in the final
patch of this series.

It's fine if maintainers want to add some of these
patches to their own queue, as long as they all make
it into linux-next.

Stephen, please add
git+ssh://master.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git config

Arnd Bergmann (17):
  hpet: kill BKL, add compat_ioctl
  proc/pci: kill BKL
  s390/block: kill the big kernel lock
  isapnp: BKL removal
  alpha: kill big kernel lock
  cris: autoconvert trivial BKL users
  m68k: remove big kernel lock
  parisc: remove big kernel lock
  sh: kill big kernel lock
  uml: kill big kernel lock
  tlclk: remove big kernel lock
  i4l: kill big kernel lock
  misdn: kill big kernel lock
  dvb/bt8xx: kill the big kernel lock
  dvb-core: kill the big kernel lock
  rtmutex-tester: make it build without BKL
  BKL: introduce CONFIG_BKL.

Al Viro (1):
  fix rawctl compat ioctls breakage on amd64 and itanic

 arch/alpha/kernel/osf_sys.c                 |    5 -
 arch/alpha/kernel/traps.c                   |    3 -
 arch/cris/arch-v10/drivers/ds1302.c         |    7 +-
 arch/cris/arch-v10/drivers/pcf8563.c        |    6 +-
 arch/cris/arch-v10/drivers/sync_serial.c    |   11 +-
 arch/cris/arch-v32/drivers/cryptocop.c      |    4 +-
 arch/cris/arch-v32/drivers/mach-a3/gpio.c   |   11 +-
 arch/cris/arch-v32/drivers/mach-fs/gpio.c   |   11 +-
 arch/cris/arch-v32/drivers/pcf8563.c        |    6 +-
 arch/cris/arch-v32/drivers/sync_serial.c    |   11 +-
 arch/m68k/kernel/sys_m68k.c                 |    7 +-
 arch/parisc/kernel/perf.c                   |    4 -
 arch/sh/kernel/ptrace_64.c                  |    9 +-
 arch/um/drivers/harddog_kern.c              |   13 +-
 arch/um/drivers/hostaudio_kern.c            |    8 +-
 arch/um/drivers/ubd_kern.c                  |    8 +-
 arch/um/kernel/exec.c                       |    2 -
 drivers/char/hpet.c                         |   98 +++++++----
 drivers/char/raw.c                          |  243 +++++++++++++++-----------
 drivers/char/tlclk.c                        |    6 +-
 drivers/gpu/drm/Kconfig                     |    5 +-
 drivers/isdn/capi/Kconfig                   |    2 +-
 drivers/isdn/i4l/isdn_tty.c                 |   11 +-
 drivers/isdn/mISDN/stack.c                  |    7 -
 drivers/media/Kconfig                       |    1 +
 drivers/media/dvb/bt8xx/dst_ca.c            |    7 +-
 drivers/media/dvb/dvb-core/dmxdev.c         |   17 +--
 drivers/media/dvb/dvb-core/dvb_ca_en50221.c |    8 +-
 drivers/media/dvb/dvb-core/dvb_net.c        |    9 +-
 drivers/media/dvb/dvb-core/dvbdev.c         |   17 +-
 drivers/net/appletalk/Kconfig               |    1 +
 drivers/pci/proc.c                          |    4 +-
 drivers/pnp/isapnp/proc.c                   |   13 +-
 drivers/s390/block/dasd.c                   |    6 -
 drivers/s390/block/dasd_ioctl.c             |   17 +--
 drivers/s390/block/dcssblk.c                |    5 -
 drivers/staging/cx25821/Kconfig             |    1 +
 drivers/staging/easycap/Kconfig             |    1 +
 drivers/staging/go7007/Kconfig              |    1 +
 drivers/staging/usbip/Kconfig               |    2 +-
 drivers/usb/gadget/Kconfig                  |    2 +-
 fs/Kconfig                                  |    1 +
 fs/adfs/Kconfig                             |    1 +
 fs/afs/Kconfig                              |    1 +
 fs/autofs/Kconfig                           |    1 +
 fs/autofs4/Kconfig                          |    1 +
 fs/ceph/Kconfig                             |    1 +
 fs/coda/Kconfig                             |    1 +
 fs/compat_ioctl.c                           |   70 --------
 fs/ecryptfs/Kconfig                         |    1 +
 fs/freevxfs/Kconfig                         |    1 +
 fs/hpfs/Kconfig                             |    1 +
 fs/jffs2/Kconfig                            |    1 +
 fs/ncpfs/Kconfig                            |    1 +
 fs/nfs/Kconfig                              |    1 +
 fs/nfsd/Kconfig                             |    1 +
 fs/ocfs2/Kconfig                            |    1 +
 fs/qnx4/Kconfig                             |    1 +
 fs/reiserfs/Kconfig                         |    1 +
 fs/smbfs/Kconfig                            |    1 +
 fs/squashfs/Kconfig                         |    1 +
 fs/udf/Kconfig                              |    1 +
 fs/ufs/Kconfig                              |    1 +
 include/linux/smp_lock.h                    |    7 +-
 init/Kconfig                                |    2 +-
 kernel/rtmutex-tester.c                     |    6 +
 kernel/trace/Kconfig                        |    1 +
 lib/Kconfig.debug                           |    9 +
 net/ipx/Kconfig                             |    1 +
 net/irda/Kconfig                            |    1 +
 net/irda/irnet/Kconfig                      |    1 +
 net/x25/Kconfig                             |    1 +
 72 files changed, 355 insertions(+), 375 deletions(-)

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Bob Picco <bob.picco@hp.com>
Cc: Clemens Ladisch <clemens@ladisch.de>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Helge Deller <deller@gmx.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Kyle McMartin <kyle@mcmartin.ca>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Gross <mark.gross@intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Roman Zippel <zippel@linux-m68k.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-alpha@vger.kernel.org
Cc: linux-cris-kernel@axis.com
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-media@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: user-mode-linux-devel@lists.sourceforge.net

------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
