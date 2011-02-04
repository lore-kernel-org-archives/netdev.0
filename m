From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH 00/20] world-writable files in sysfs and debugfs
Date: Fri, 4 Feb 2011 17:00:33 +0300
Message-ID: <20110204140033.GA31184@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-usb@vger.kernel.org, linux-media@vger.kernel.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org,
	acpi4asus-user@lists.sourceforge.net, rtc-linux@googlegroups.com,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-mtd@lists.infradead.org, security@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Disposition: inline
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The search was made with trivial shell commands:

find | xargs grep S_IWUGO
find | xargs grep S_IWOTH

I didn't precisely investigate how exactly one may damage the
system/hardware because of issues number, maybe the harm is very limited
in case of some of these drivers.

One suspicious file is ./staging/speakup/speakup.h, but it explitly calls
macros as world-writable.  I didn't check what speakup's world-writable
files provide because it requires some knowledge about the hardware.


Vasiliy Kulikov (20):
  mach-omap2: mux: world-writable debugfs files
  mach-omap2: pm: world-writable debugfs timer files
  mach-omap2: smartreflex: world-writable debugfs voltage files
  mach-ux500: mbox-db5500: world-writable sysfs fifo file
  leds: lp5521: world-writable sysfs engine* files
  leds: lp5523: world-writable engine* sysfs files
  video: sn9c102: world-wirtable sysfs files
  mfd: ab3100: world-writable debugfs *_priv files
  mfd: ab3500: world-writable debugfs register-* files
  mfd: ab8500: world-writable debugfs register-* files
  misc: ep93xx_pwm: world-writable sysfs files
  net: can: at91_can: world-writable sysfs files
  net: can: janz-ican3: world-writable sysfs termination file
  platform: x86: acer-wmi: world-writable sysfs threeg file
  platform: x86: asus_acpi: world-writable procfs files
  platform: x86: tc1100-wmi: world-writable sysfs wireless and jogdial files
  rtc: rtc-ds1511: world-writable sysfs nvram file
  scsi: aic94xx: world-writable sysfs update_bios file
  scsi: iscsi: world-writable sysfs priv_sess file
  fs: ubifs: world-writable debugfs dump_* files

 arch/arm/mach-omap2/mux.c                  |    2 +-
 arch/arm/mach-omap2/pm-debug.c             |    8 ++++----
 arch/arm/mach-omap2/smartreflex.c          |    4 ++--
 arch/arm/mach-ux500/mbox-db5500.c          |    2 +-
 drivers/leds/leds-lp5521.c                 |   14 +++++++-------
 drivers/leds/leds-lp5523.c                 |   20 ++++++++++----------
 drivers/media/video/sn9c102/sn9c102_core.c |    6 +++---
 drivers/mfd/ab3100-core.c                  |    4 ++--
 drivers/mfd/ab3550-core.c                  |    6 +++---
 drivers/mfd/ab8500-debugfs.c               |    6 +++---
 drivers/misc/ep93xx_pwm.c                  |    6 +++---
 drivers/net/can/at91_can.c                 |    2 +-
 drivers/net/can/janz-ican3.c               |    2 +-
 drivers/platform/x86/acer-wmi.c            |    2 +-
 drivers/platform/x86/asus_acpi.c           |    8 +-------
 drivers/platform/x86/tc1100-wmi.c          |    2 +-
 drivers/rtc/rtc-ds1511.c                   |    2 +-
 drivers/scsi/aic94xx/aic94xx_init.c        |    2 +-
 drivers/scsi/scsi_transport_iscsi.c        |    2 +-
 fs/ubifs/debug.c                           |    6 +++---
 20 files changed, 50 insertions(+), 56 deletions(-)

--
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
