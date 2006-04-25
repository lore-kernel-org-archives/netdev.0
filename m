From: Dan Williams <dcbw@redhat.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 24 Apr 2006 20:33:02 -0400
Message-ID: <1145925182.9369.1.camel@localhost.localdomain>
References: <20060424194006.GB21761@tuxdriver.com>
	 <20060424204044.GC21761@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58090 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932143AbWDYAes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 20:34:48 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060424204044.GC21761@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-24 at 16:40 -0400, John W. Linville wrote:
> The following changes since commit 7c241d37fe0e6442c5cf3b5d73f7f58f2dc66352:
>   Michael Buesch:
>         bcm43xx: make PIO mode usable
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Dan Williams:
>       wireless/airo: minimal WPA awareness
> 
> Jiri Benc:
>       orinoco: fix BAP0 offset error after several days of operation
> 
> Johannes Berg:
>       softmac: add SIOCSIWMLME
>       softmac: clean up event handling code

Any way to get the event handling cleanup patch into 2.6.17?  It's
pretty much a bugfix and bcm43xx is useless with wpa_supplicant and NM
without the patch...

Dan

> Michael Buesch:
>       bcm43xx: use pci_iomap() for convenience.
> 
> Pavel Roskin:
>       orinoco: Remove useless CIS validation
>       orinoco: remove PCMCIA audio support, it's useless for wireless cards
>       orinoco: remove underscores from little-endian field names
>       orinoco: remove tracing code, it's unused
>       orinoco: remove debug buffer code and userspace include support
>       orinoco: Symbol card supported by spectrum_cs is LA4137, not LA4100
>       orinoco: optimize Tx exception handling in orinoco
>       orinoco: orinoco_xmit() should only return valid symbolic constants
>       orinoco replace hermes_write_words() with hermes_write_bytes()
>       orinoco: don't use any padding for Tx frames
>       orinoco: refactor and clean up Tx error handling
>       orinoco: simplify 802.3 encapsulation code
>       orinoco: delay FID allocation after firmware initialization
>       orinoco_pci: disable device and free IRQ when suspending
>       orinoco_pci: use pci_iomap() for resources
>       orinoco: support PCI suspend/resume for Nortel, PLX and TMD adaptors
>       orinoco: reduce differences between PCI drivers, create orinoco_pci.h
>       orinoco: further comment cleanup in the PCI drivers
>       orinoco: bump version to 0.15
> 
> Zhu Yi:
>       ieee80211: Fix TKIP MIC calculation for QoS frames
>       ieee80211: Fix TX code doesn't enable QoS when using WPA + QoS
>       ieee80211: export list of bit rates with standard WEXT procddures
>       ieee80211: remove unnecessary CONFIG_WIRELESS_EXT checking
>       ieee80211: replace debug IEEE80211_WARNING with each own debug macro
>       ieee80211: update version stamp to 1.1.13
>       ipw2200: Exponential averaging for signal and noise Level
>       ipw2200: Fix TX QoS enabled frames problem
>       ipw2200: generates a scan event after a scan has completed
>       ipw2200: add module_param support for antenna selection
>       ipw2200: fix compile warning when !CONFIG_IPW2200_DEBUG
>       ipw2200: Do not continue loading the firmware if kmalloc fails
>       ipw2200: turn off signal debug log
>       ipw2200: Set the 'fixed' flags in wext get_rate
>       ipw2200: Fix endian issues with v3.0 fw image format
>       README.ipw2200: rename CONFIG_IPW_DEBUG to CONFIG_IPW2200_DEBUG
>       ipw2200: Enable rtap interface for RF promiscuous mode while associated
>       ipw2200: version string rework
>       ipw2200: update version stamp to 1.1.2
>       ipw2200: rename CONFIG_IPW_QOS to CONFIG_IPW2200_QOS
>       wireless Kconfig add IPW2200_RADIOTAP
>       ipw2200: rename CONFIG_IEEE80211_RADIOTAP to CONFIG_IPW2200_RADIOTAP
>       ipw2200: remove priv->last_noise reference
>       ipw2200: Fix wpa_supplicant association problem
> 
>  Documentation/networking/README.ipw2200        |   10 
>  drivers/net/wireless/Kconfig                   |   30 +
>  drivers/net/wireless/airo.c                    |  271 +++++---
>  drivers/net/wireless/bcm43xx/bcm43xx.h         |    1 
>  drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |    2 
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c    |   27 -
>  drivers/net/wireless/hermes.c                  |   66 --
>  drivers/net/wireless/hermes.h                  |   43 -
>  drivers/net/wireless/ipw2200.c                 |  849 +++++++++++++++++++++---
>  drivers/net/wireless/ipw2200.h                 |   83 ++
>  drivers/net/wireless/orinoco.c                 |  251 ++-----
>  drivers/net/wireless/orinoco.h                 |   19 -
>  drivers/net/wireless/orinoco_cs.c              |    9 
>  drivers/net/wireless/orinoco_nortel.c          |  168 +++--
>  drivers/net/wireless/orinoco_pci.c             |  207 +-----
>  drivers/net/wireless/orinoco_pci.h             |  125 ++++
>  drivers/net/wireless/orinoco_plx.c             |  222 +++---
>  drivers/net/wireless/orinoco_tmd.c             |   96 +--
>  drivers/net/wireless/spectrum_cs.c             |   48 +
>  include/net/ieee80211.h                        |    6 
>  include/net/ieee80211softmac_wx.h              |    5 
>  net/ieee80211/ieee80211_crypt_tkip.c           |   11 
>  net/ieee80211/ieee80211_rx.c                   |   18 -
>  net/ieee80211/ieee80211_tx.c                   |   63 +-
>  net/ieee80211/ieee80211_wx.c                   |   44 +
>  net/ieee80211/softmac/ieee80211softmac_assoc.c |    2 
>  net/ieee80211/softmac/ieee80211softmac_event.c |   25 -
>  net/ieee80211/softmac/ieee80211softmac_priv.h  |    1 
>  net/ieee80211/softmac/ieee80211softmac_wx.c    |   32 +
>  29 files changed, 1673 insertions(+), 1061 deletions(-)
>  create mode 100644 drivers/net/wireless/orinoco_pci.h
> 
> Patch included as attachment due to size concerns.

