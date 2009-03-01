From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] WiMAX-next for 2.6.30
Date: Sun, 1 Mar 2009 01:56:50 -0800
Message-ID: <200903010156.51110.inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
Content-Disposition: inline
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Apologies, I just realized I missed sending the cover letter

This patch series corresponds to the wimax-next tree as it stands
today, with feature additions for the i2400m driver:

 - support extended data-RX protocol and data-RX reordering
 - ability to query for a list of firmware files if the default
   doesn't work
 - control of base station idle mode timeout (with firmware >= 1.4).

The wimax stack NAP level interface (scan, connect, disconnect, etc) 
that has been proposed in the mailing list is still not really ready 
for merging, so it will be kept in a branch of wimax-next.

Harvey Harrison (1):
  wimax: replace uses of __constant_{endian}

Inaky Perez-Gonzalez (6):
  wimax/i2400m: add the ability to fallback to other firmware files if
    the default is not there
  wimax/i2400m: drop support for deprecated major fw interface, add for
    new minor
  wimax/i2400m: firmware_check() encodes the firmware version in
    i2400m->fw_version
  wimax/i2400m: allow control of the base-station idle mode timeout
  wimax/i2400m: support extended data RX protocol (no need to
    reallocate skbs)
  wimax/i2400m: implement RX reorder support

Kay Sievers (1):
  wimax: struct device - replace bus_id with dev_name(), dev_set_name()

 drivers/net/wimax/i2400m/Makefile       |    1 +
 drivers/net/wimax/i2400m/control.c      |  147 +++++-
 drivers/net/wimax/i2400m/debug-levels.h |    1 +
 drivers/net/wimax/i2400m/driver.c       |   28 ++-
 drivers/net/wimax/i2400m/fw.c           |   53 ++-
 drivers/net/wimax/i2400m/i2400m.h       |   75 +++-
 drivers/net/wimax/i2400m/netdev.c       |  106 ++++-
 drivers/net/wimax/i2400m/rx.c           |  746 
++++++++++++++++++++++++++++++-
 drivers/net/wimax/i2400m/sdio.c         |   11 +-
 drivers/net/wimax/i2400m/sysfs.c        |   80 ++++
 drivers/net/wimax/i2400m/usb-notif.c    |    2 +-
 drivers/net/wimax/i2400m/usb.c          |   14 +-
 include/linux/wimax/debug.h             |    2 +-
 include/linux/wimax/i2400m.h            |   69 +++
 14 files changed, 1240 insertions(+), 95 deletions(-)
 create mode 100644 drivers/net/wimax/i2400m/sysfs.c


-- 
Inaky
