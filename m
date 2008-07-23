From: Jiri Slaby <jirislaby@gmail.com>
Subject: q == &noop_qdisc warning from 802.11 code
Date: Wed, 23 Jul 2008 14:28:47 +0200
Message-ID: <488723FF.8070707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Michael Wu <flamingice@sourmilk.net>,
	linux-wireless <linux-wirel
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:15575 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbYGWMbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 08:31:04 -0400
Received: by nf-out-0910.google.com with SMTP id d3so847531nfc.21
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 05:31:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I hit the warning from __netif_schedule:

wlan0: Trigger new scan to find an IBSS to join
------------[ cut here ]------------
WARNING: at net/core/dev.c:1334 __netif_schedule+0x6f/0x80()
Modules linked in: ath5k arc4 ecb crypto_blkcipher cryptomgr crypto_algapi 
mac80211 led_class usbhid cfg80211 ohci1394 hid ff_memless ieee1394 evdev 
rtc_cmos floppy [last unloaded: ath5k]
Pid: 4342, comm: ath5k_pci Not tainted 2.6.26-mm1_64 #429

Call Trace:
  [<ffffffff8023b3ff>] warn_on_slowpath+0x5f/0x90
  [<ffffffff802ac545>] ? check_object+0x235/0x270
  [<ffffffff802aae00>] ? init_object+0x50/0x90
  [<ffffffff802ad98d>] ? __slab_free+0x28d/0x360
  [<ffffffff8054bea3>] ? wireless_send_event+0x173/0x310
  [<ffffffffa009a843>] ? ath5k_hw_set_rx_filter+0x103/0x110 [ath5k]
  [<ffffffffa009a9e0>] ? ath5k_hw_set_mcast_filter+0x50/0x60 [ath5k]
  [<ffffffffa0098c23>] ? ath5k_configure_filter+0x1a3/0x200 [ath5k]
  [<ffffffff804bcb1f>] __netif_schedule+0x6f/0x80
  [<ffffffffa007b703>] ieee80211_scan_completed+0x243/0x300 [mac80211]
  [<ffffffffa007b84f>] ieee80211_sta_scan_work+0x8f/0x210 [mac80211]
  [<ffffffffa007b7c0>] ? ieee80211_sta_scan_work+0x0/0x210 [mac80211]
  [<ffffffff8024dc90>] run_workqueue+0x70/0x120
  [<ffffffff8024df47>] worker_thread+0xa7/0x120
  [<ffffffff802521b0>] ? autoremove_wake_function+0x0/0x40
  [<ffffffff8024dea0>] ? worker_thread+0x0/0x120
  [<ffffffff80251df9>] kthread+0x49/0x90
  [<ffffffff8020d549>] child_rip+0xa/0x11
  [<ffffffff80251db0>] ? kthread+0x0/0x90
  [<ffffffff8020d53f>] ? child_rip+0x0/0x11

---[ end trace bfbab62b1ce8da42 ]---

What causes it? I did:
# insmod  ath5k.ko
# iwconfig wlan0 mode ad-hoc
# iwconfig wlan0 channel 2 essid bubak

No link up, the link is still down:
6: wmaster0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
     link/ieee802.11 00:0b:6b:80:f0:5d brd ff:ff:ff:ff:ff:ff
7: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
     link/ether 00:0b:6b:80:f0:5d brd ff:ff:ff:ff:ff:ff

Is this a mac80211 issue?
