From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/12] autoconvert trivial BKL users to private mutex
Date: Sun, 11 Jul 2010 23:18:51 +0200
Message-ID: <1278883143-29035-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Jesper Nilsson <jesper.nilsson@axis.com>,
	linux-usb@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Corey Minyard <minyard@acm.org>, linux-cris-kernel@axis.com,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Karsten Keil <isdn@linux-pingi.de>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-scsi@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	linux-mtd@lists.infradead.org, John Kacur <jkacur@redhat.com>,
	netdev@vger.kernel.org, linux-media@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>,
	David Woodhouse <David.Woodhouse@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

This is a repost of an earlier patch to remove
those users of the big kernel lock that can be
converted to a mutex using a simple script.

The only use of the BKL is in file operations
that are called without any other lock, so the
new mutex is the top-level serialization
and cannot introduce any AB-BA deadlock.

Please apply to the respective maintainer trees
if the patches look good.

Arnd Bergmann (12):
  staging: autoconvert trivial BKL users to private mutex
  isdn: autoconvert trivial BKL users to private mutex
  scsi: autoconvert trivial BKL users to private mutex
  media: autoconvert trivial BKL users to private mutex
  usb: autoconvert trivial BKL users to private mutex
  net: autoconvert trivial BKL users to private mutex
  cris: autoconvert trivial BKL users to private mutex
  sbus: autoconvert trivial BKL users to private mutex
  mtd: autoconvert trivial BKL users to private mutex
  mac: autoconvert trivial BKL users to private mutex
  ipmi: autoconvert trivial BKL users to private mutex
  drivers: autoconvert trivial BKL users to private mutex

 arch/cris/arch-v10/drivers/eeprom.c        |    2 -
 arch/cris/arch-v10/drivers/i2c.c           |    2 -
 arch/cris/arch-v32/drivers/cryptocop.c     |    2 -
 arch/cris/arch-v32/drivers/i2c.c           |   12 ++++----
 drivers/block/paride/pg.c                  |    7 ++--
 drivers/block/paride/pt.c                  |   19 ++++++------
 drivers/char/apm-emulation.c               |   11 ++++---
 drivers/char/applicom.c                    |    9 +++--
 drivers/char/ds1302.c                      |   15 +++++----
 drivers/char/ds1620.c                      |    8 ++--
 drivers/char/dsp56k.c                      |   27 +++++++++--------
 drivers/char/dtlk.c                        |    8 ++--
 drivers/char/generic_nvram.c               |    7 ++--
 drivers/char/genrtc.c                      |   13 ++++----
 drivers/char/i8k.c                         |    7 ++--
 drivers/char/ip2/ip2main.c                 |    8 ++--
 drivers/char/ipmi/ipmi_devintf.c           |   14 ++++----
 drivers/char/ipmi/ipmi_watchdog.c          |    8 ++--
 drivers/char/lp.c                          |   15 +++++----
 drivers/char/mbcs.c                        |    8 ++--
 drivers/char/mmtimer.c                     |    7 ++--
 drivers/char/mwave/mwavedd.c               |   44 ++++++++++++++--------------
 drivers/char/nvram.c                       |   11 ++++---
 drivers/char/nwflash.c                     |   12 ++++----
 drivers/char/pcmcia/cm4000_cs.c            |   11 ++++---
 drivers/char/pcmcia/cm4040_cs.c            |    7 ++--
 drivers/char/ppdev.c                       |    8 ++--
 drivers/char/rio/rio_linux.c               |    7 ++--
 drivers/char/snsc.c                        |    9 +++--
 drivers/char/toshiba.c                     |    9 +++--
 drivers/char/viotape.c                     |   11 ++++---
 drivers/char/xilinx_hwicap/xilinx_hwicap.c |    6 ++--
 drivers/hwmon/fschmd.c                     |    6 ++--
 drivers/hwmon/w83793.c                     |    6 ++--
 drivers/input/misc/hp_sdc_rtc.c            |    7 ++--
 drivers/isdn/capi/capi.c                   |    6 ++--
 drivers/isdn/divert/divert_procfs.c        |    7 ++--
 drivers/isdn/hardware/eicon/divamnt.c      |    7 ++--
 drivers/isdn/hardware/eicon/divasi.c       |    2 -
 drivers/isdn/hardware/eicon/divasmain.c    |    2 -
 drivers/isdn/hysdn/hysdn_procconf.c        |   21 +++++++------
 drivers/isdn/hysdn/hysdn_proclog.c         |   15 +++++----
 drivers/isdn/i4l/isdn_common.c             |   27 +++++++++--------
 drivers/isdn/mISDN/timerdev.c              |    7 ++--
 drivers/macintosh/adb.c                    |   10 +++---
 drivers/macintosh/smu.c                    |    6 ++--
 drivers/macintosh/via-pmu.c                |   11 ++++---
 drivers/media/dvb/bt8xx/dst_ca.c           |    7 ++--
 drivers/media/video/cx88/cx88-blackbird.c  |   13 ++++----
 drivers/media/video/dabusb.c               |   18 ++++++------
 drivers/media/video/se401.c                |    9 +++--
 drivers/media/video/stradis.c              |    9 +++--
 drivers/media/video/usbvideo/vicam.c       |   14 ++++----
 drivers/message/fusion/mptctl.c            |   15 +++++----
 drivers/message/i2o/i2o_config.c           |   23 +++++++-------
 drivers/misc/phantom.c                     |   11 ++++---
 drivers/mtd/mtdchar.c                      |   15 +++++----
 drivers/net/ppp_generic.c                  |   19 ++++++------
 drivers/net/wan/cosa.c                     |   10 +++---
 drivers/pci/hotplug/cpqphp_sysfs.c         |   13 ++++----
 drivers/rtc/rtc-m41t80.c                   |   13 ++++----
 drivers/sbus/char/display7seg.c            |    8 ++--
 drivers/sbus/char/envctrl.c                |    2 -
 drivers/sbus/char/flash.c                  |   15 +++++----
 drivers/sbus/char/openprom.c               |   15 +++++----
 drivers/sbus/char/uctrl.c                  |    7 ++--
 drivers/scsi/3w-9xxx.c                     |    7 ++--
 drivers/scsi/3w-sas.c                      |    7 ++--
 drivers/scsi/3w-xxxx.c                     |    9 ++---
 drivers/scsi/aacraid/linit.c               |   15 +++++----
 drivers/scsi/ch.c                          |    8 ++--
 drivers/scsi/dpt_i2o.c                     |   18 ++++++------
 drivers/scsi/gdth.c                        |   11 ++++---
 drivers/scsi/megaraid.c                    |    8 ++--
 drivers/scsi/megaraid/megaraid_mm.c        |    8 ++--
 drivers/scsi/megaraid/megaraid_sas.c       |    2 -
 drivers/scsi/mpt2sas/mpt2sas_ctl.c         |   11 ++++---
 drivers/scsi/osst.c                        |   15 +++++----
 drivers/scsi/scsi_tgt_if.c                 |    2 -
 drivers/scsi/sg.c                          |   11 ++++---
 drivers/staging/crystalhd/crystalhd_lnx.c  |    9 +++--
 drivers/staging/dt3155/dt3155_drv.c        |    6 ++-
 drivers/staging/vme/devices/vme_user.c     |    7 ++--
 drivers/telephony/ixj.c                    |    7 ++--
 drivers/usb/gadget/printer.c               |    7 ++--
 drivers/usb/misc/iowarrior.c               |   15 +++++----
 drivers/usb/misc/rio500.c                  |   15 +++++----
 drivers/usb/misc/usblcd.c                  |   16 +++++-----
 drivers/watchdog/cpwd.c                    |   15 +++++----
 fs/hfsplus/ioctl.c                         |   11 ++++---
 net/wanrouter/wanmain.c                    |    7 ++--
 net/wanrouter/wanproc.c                    |    7 ++--
 92 files changed, 505 insertions(+), 469 deletions(-)

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Corey Minyard <minyard@acm.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: "James E.J. Bottomley" <James.Bottomley@suse.de>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
Cc: netdev@vger.kernel.org
Cc: openipmi-developer@lists.sourceforge.net
Cc: devel@driverdev.osuosl.org
Cc: linux-cris-kernel@axis.com
Cc: linux-media@vger.kernel.org
Cc: linux-mtd@lists.infradead.org
Cc: linuxppc-dev@ozlabs.org
Cc: linux-scsi@vger.kernel.org
Cc: linux-usb@vger.kernel.org
