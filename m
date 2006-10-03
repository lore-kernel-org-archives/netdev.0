From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull bcm43xx-d80211 bugfixes and new features
Date: Mon, 02 Oct 2006 22:44:59 -0500
Message-ID: <4521DCBB.2030201@lwfinger.net>
References: <200610021843.20694.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:42233 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932328AbWJCDpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 23:45:08 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610021843.20694.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Hi John,
> 
> Please pull from my tree
> git pull http://bu3sch.de/git/wireless-dev.git for-linville
> 
> This will pull various bugfixes and feature improvements.
> Most noteably it will pull a bugfix for a crash introduced
> by an earlier patch to d80211 which changed RX status information
> handling.
> 
> The new features include support for the new v4 firmware.
> I also did my homework to get better support for OpenWRT
> devices in ssb.
> 
> 
> The list of pulled changesets is:
> 
> Michael Buesch:
>       ssb: Abstract bus accesses.
>       bcm43xx-d80211: convert to ssb abstract bus access API
>       bcm43xx-d80211: Don't crash if we use v4 firmware.
>       bcm43xx-d80211: Always make fwpostfix option available.
>       bcm43xx-d80211: Firmware revision/patchlevel detection.
>       bcm43xx-d80211: Add support for v4 firmware.
>       bcm43xx-d80211: add SHM constants
>       bcm43xx-d80211: Don't use low level netif and ieee80211_netif_oper functions.
>       bcm43xx-d80211: DMA-mask fixes.
>       bcm43xx-d80211: Remove some BCM947XX ifdefs,
>       Merge branch 'master' of git://kernel.org/.../linville/wireless-dev
>       bcm43xx-d80211: Assign all fields in the RX status report.
>       bcm43xx-d80211: Set channel cookie to prevent ghost packets.
>       bcm43xx-d80211: Prevent crash by setting active wlcore to NULL on wlcore-select failure.
> 
> 
> The diffstat is:
> 
>  drivers/misc/ssb.c                                 |  431 ++++++-----
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |  143 +++
>  .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c  |  295 +++-----
>  .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h  |   35 -
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |  149 ++--
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h  |   18 
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c |   16 
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |  820 +++++++++-----------
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c  |   76 +-
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c  |  104 +--
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h  |   12 
>  .../net/wireless/d80211/bcm43xx/bcm43xx_power.c    |  125 +---
>  .../net/wireless/d80211/bcm43xx/bcm43xx_radio.c    |  143 ++--
>  .../net/wireless/d80211/bcm43xx/bcm43xx_radio.h    |    1 
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |  309 +++++++-
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h |  247 +++++-
>  include/linux/ssb.h                                |   71 +-
>  17 files changed, 1681 insertions(+), 1314 deletions(-)
> 
Michael,

There is something wrong with wireless-dev after I pulled your changes. The logs are:

kernel: ssb: Core 0 found: cc 0800, rev 02, vendor 4243
kernel: ssb: Core 1 found: cc 0812, rev 04, vendor 4243
kernel: ssb: Core 2 found: cc 080D, rev 01, vendor 4243
kernel: ssb: Core 3 found: cc 0807, rev 01, vendor 4243
kernel: ssb: Core 4 found: cc 0804, rev 07, vendor 4243
kernel: ssb: Core 5 found: cc 0812, rev 04, vendor 4243
kernel: bcm43xx_d80211: Ignoring additional 802.11 core.
kernel: bcm43xx_d80211: Broadcom 4306 WLAN found
kernel: ssb: Switching to core 4
kernel: bcm43xx_d80211: PHY connected
kernel: ssb: Switching to core 1
kernel: bcm43xx_d80211: Detected PHY: Version: 1, Type 2, Revision 1
kernel: bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
kernel: bcm43xx_d80211: Radio turned off
kernel: bcm43xx_d80211: Radio turned off
kernel: wmaster0: Selected rate control algorithm 'simple'
kernel: bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 4, MAC: 00
:06:25:40:6f:03)
kernel: bcm43xx_d80211: PHY connected
kernel: bcm43xx_d80211: PHY disconnected
kernel: bcm43xx_d80211: PHY connected
kernel: bcm43xx_d80211: firmware revision FE84, patchlevel 90B4, date 2000-14-248
  29:46:18
kernel: ssb: Switching to core 0
kernel: ssb: Switching to core 1
kernel: bcm43xx_d80211: Radio turned on
kernel: bcm43xx_d80211: Chip initialized
kernel: bcm43xx_d80211: 30-bit DMA initialized
kernel: bcm43xx_d80211: TODO: Incomplete code in keymac_write() at 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:871
.....
kernel: bcm43xx_d80211: Keys cleared
kernel: bcm43xx_d80211: Selected 802.11 core (phytype 2)
kernel: wmaster0: Does not support passive scan, disabled
kernel: wlan1: starting scan
kernel: HW CONFIG: channel=1 freq=2412 phymode=3
kernel: HW CONFIG: channel=2 freq=2417 phymode=3
kernel: bcm43xx_d80211: FATAL ERROR: BCM43xx_IRQ_XMIT_ERROR
kernel: bcm43xx_d80211: ASSERTION FAILED (0) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c:1020:parse_cookie()
kernel: bcm43xx_d80211: ASSERTION FAILED (ring && *slot >= 0 && *slot < ring->nr_slots) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c:1023:parse_cookie()
kernel: bcm43xx_d80211: FATAL ERROR: BCM43xx_IRQ_XMIT_ERROR
kernel: bcm43xx_d80211: ASSERTION FAILED (0) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c:1020:parse_cookie()
kernel: bcm43xx_d80211: ASSERTION FAILED (ring && *slot >= 0 && *slot < ring->nr_
slots) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c:1023:parse_cookie()

If you need any other info, please contact me.

Larry
