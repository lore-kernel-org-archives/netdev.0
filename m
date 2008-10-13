From: Ingo Molnar <mingo@elte.hu>
Subject: [build bug] CONFIG_MAC80211=m && CONFIG_RT2X00=y
Date: Mon, 13 Oct 2008 09:40:40 +0200
Message-ID: <20081013074040.GA28840@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ivo van Doorn <IvDoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52163 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754635AbYJMHkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 03:40:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

FYI, i triggered a build failure and have the hack below in -tip. Did 
not have time to track down why the build fails exactly, so i disabled 
the driver as a quick hack. Would be glad to test any fix patch.

	Ingo

---------------->
>From c6ebfd926090777d5a07610e5bbf1dcfae047eab Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 12 Oct 2008 13:54:57 +0200
Subject: [PATCH] rtx2x00: disable for now

doesnt build when CONFIG_MAC80211=m && CONFIG_RT2X00=y:

drivers/built-in.o: In function `rt2x00lib_intf_scheduled':
rt2x00dev.c:(.text+0x1cfb7f): undefined reference to `ieee80211_iterate_active_interfaces'
drivers/built-in.o: In function `rt2x00lib_remove_hw':
rt2x00dev.c:(.text+0x1cfdf5): undefined reference to `ieee80211_unregister_hw'
drivers/built-in.o: In function `rt2x00lib_rxdone':
(.text+0x1d0234): undefined reference to `ieee80211_get_hdrlen_from_skb'
drivers/built-in.o: In function `rt2x00lib_rxdone':
(.text+0x1d03d2): undefined reference to `ieee80211_rx_irqsafe'
drivers/built-in.o: In function `rt2x00lib_txdone':
(.text+0x1d05f3): undefined reference to `ieee80211_tx_status_irqsafe'
drivers/built-in.o: In function `rt2x00lib_txdone':
(.text+0x1d064b): undefined reference to `ieee80211_wake_queue'
drivers/built-in.o: In function `rt2x00lib_beacondone':
(.text+0x1d06f9): undefined reference to `ieee80211_iterate_active_interfaces_atomic'
drivers/built-in.o: In function `rt2x00lib_disable_radio':
(.text+0x1d08a8): undefined reference to `ieee80211_stop_queues'
drivers/built-in.o: In function `rt2x00lib_probe_dev':
(.text+0x1d0d1a): undefined reference to `ieee80211_register_hw'
drivers/built-in.o: In function `rt2x00lib_resume':
(.text+0x1d0e6a): undefined reference to `ieee80211_iterate_active_interfaces'
drivers/built-in.o: In function `rt2x00lib_resume':
(.text+0x1d0e7b): undefined reference to `ieee80211_wake_queues'
drivers/built-in.o: In function `rt2x00lib_resume':
(.text+0x1d0e8e): undefined reference to `ieee80211_iterate_active_interfaces'
drivers/built-in.o: In function `rt2x00lib_enable_radio':
(.text+0x1d0fcd): undefined reference to `ieee80211_wake_queues'
drivers/built-in.o: In function `rt2x00mac_tx':
(.text+0x1d195e): undefined reference to `ieee80211_stop_queue'
drivers/built-in.o: In function `rt2x00mac_tx':
(.text+0x1d19a6): undefined reference to `ieee80211_stop_queue'
drivers/built-in.o: In function `rt2x00mac_tx':
(.text+0x1d1abc): undefined reference to `ieee80211_ctstoself_get'
drivers/built-in.o: In function `rt2x00mac_tx':
(.text+0x1d1b1a): undefined reference to `ieee80211_rts_get'
drivers/built-in.o: In function `rt2x00queue_create_tx_descriptor':
rt2x00queue.c:(.text+0x1d2db7): undefined reference to `ieee80211_get_hdrlen_from_skb'
drivers/built-in.o: In function `rt2x00queue_update_beacon':
(.text+0x1d2e54): undefined reference to `ieee80211_beacon_get'
drivers/built-in.o: In function `rt2x00crypto_tx_insert_iv':
(.text+0x1d3798): undefined reference to `ieee80211_get_hdrlen_from_skb'
drivers/built-in.o: In function `rt2x00crypto_tx_remove_iv':
(.text+0x1d3860): undefined reference to `ieee80211_get_hdrlen_from_skb'
drivers/built-in.o: In function `rt2x00pci_remove':
(.text+0x1d480b): undefined reference to `ieee80211_free_hw'
drivers/built-in.o: In function `rt2x00pci_probe':
(.text+0x1d48d0): undefined reference to `ieee80211_alloc_hw'
drivers/built-in.o: In function `rt2x00pci_probe':
(.text+0x1d4909): undefined reference to `ieee80211_free_hw'
---
 drivers/net/wireless/rt2x00/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index f839ce0..8d02224 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -1,6 +1,7 @@
 menuconfig RT2X00
 	bool "Ralink driver support"
 	depends on MAC80211 && WLAN_80211 && EXPERIMENTAL
+	depends on BROKEN
 	---help---
 	  This will enable the experimental support for the Ralink drivers,
 	  developed in the rt2x00 project <http://rt2x00.serialmonkey.com>.
