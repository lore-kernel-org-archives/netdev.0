From: Jeff Garzik <jgarzik@pobox.com>
Subject: wireless-2.6 queue updated
Date: Wed, 11 Aug 2004 18:01:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811220107.GA1923@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Just updated to latest kernel.  No new changes committed.

BK users:

	bk pull bk://gkernel.bkbits.net/wireless-2.6

Patch:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.8-rc4-bk1-wireless1.patch.bz2

This will update the following files:

 MAINTAINERS                                     |    7 
 drivers/net/wireless/Kconfig                    |    2 
 drivers/net/wireless/Makefile                   |    2 
 drivers/net/wireless/hostap/Kconfig             |  101 
 drivers/net/wireless/hostap/Makefile            |    8 
 drivers/net/wireless/hostap/hostap.c            | 1178 ++++++++
 drivers/net/wireless/hostap/hostap.h            |   57 
 drivers/net/wireless/hostap/hostap_80211.h      |  107 
 drivers/net/wireless/hostap/hostap_80211_rx.c   | 1066 +++++++
 drivers/net/wireless/hostap/hostap_80211_tx.c   |  510 +++
 drivers/net/wireless/hostap/hostap_ap.c         | 3227 +++++++++++++++++++++
 drivers/net/wireless/hostap/hostap_ap.h         |  271 +
 drivers/net/wireless/hostap/hostap_common.h     |  556 +++
 drivers/net/wireless/hostap/hostap_config.h     |   86 
 drivers/net/wireless/hostap/hostap_crypt.c      |  167 +
 drivers/net/wireless/hostap/hostap_crypt.h      |   50 
 drivers/net/wireless/hostap/hostap_crypt_ccmp.c |  486 +++
 drivers/net/wireless/hostap/hostap_crypt_tkip.c |  696 ++++
 drivers/net/wireless/hostap/hostap_crypt_wep.c  |  281 +
 drivers/net/wireless/hostap/hostap_cs.c         |  771 +++++
 drivers/net/wireless/hostap/hostap_download.c   |  758 +++++
 drivers/net/wireless/hostap/hostap_hw.c         | 3525 ++++++++++++++++++++++++
 drivers/net/wireless/hostap/hostap_info.c       |  469 +++
 drivers/net/wireless/hostap/hostap_ioctl.c      | 3468 +++++++++++++++++++++++
 drivers/net/wireless/hostap/hostap_pci.c        |  413 ++
 drivers/net/wireless/hostap/hostap_plx.c        |  598 ++++
 drivers/net/wireless/hostap/hostap_proc.c       |  466 +++
 drivers/net/wireless/hostap/hostap_wlan.h       | 1074 +++++++
 28 files changed, 20400 insertions(+)

through these ChangeSets:

<jkmaline@cc.hut.fi> (04/06/03 1.1722.86.2)
   [PATCH] fix hostap crypto bugs
   
   On Wed, Jun 02, 2004 at 09:36:34PM -0700, David S. Miller wrote:
   
   > You cannot invoke virt_to_page() on addresses on the kernel stack,
   > and that is what the various HostAP crypto modules are doing.
   >
   > This happens to work on some platforms, but it is going to explode
   > on others.
   
   Thanks! I have not updated my non-x86 platforms to 2.6 kernels, so I had
   not yet had a change to explode anything with this..
   
   > Allocate these little header scratch area blobs in the per-crypto-instance
   > structs you kmalloc instead.
   
   This patch (for wireless-2.6) should do this. I used separate buffers
   for RX and TX because they could be in theory called concurrently.
   Better to get this first working, but it might be worthwhile to consider
   the memory use at some point. This version uses 112 bytes of additional
   scratch buffers per key for CCMP.

<jkmaline@cc.hut.fi> (04/06/02 1.1722.86.1)
   Add HostAP wireless driver.
