From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: BUG: rt2x00usb: Vendor Request 0x07 failed
Date: Mon, 22 Aug 2011 10:25:09 +0200
Message-ID: <20110822082507.GB2422@redhat.com>
References: <4E4F7364.2060609@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, Netdev@vger.kernel.org,
	Gertjan van Wingerde <gwingerde@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E4F7364.2060609@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Sat, Aug 20, 2011 at 10:42:12AM +0200, Marc Kleine-Budde wrote:
> I'm a running a sheeva plug (ARM/kirkwood) with a rt2800 USB stick in AP mode.
> Bus 001 Device 002: ID 1737:0071 Linksys WUSB600N v1 Dual-Band Wireless-N Network Adapter [Ralink RT2870]

First of all, the best way to get rt2x00 support is write to
(moderated for non-subscribers) list users@rt2x00.serialmonkey.com 

> kernel is v3.0.3 +
> http://www.spinics.net/lists/linux-wireless/msg74377.html
> (see http://git.pengutronix.de/?p=mkl/linux-2.6.git;a=shortlog;h=refs/heads/wireless/rt2x00/v3.0.3)

We have now wireless-testing applied version of that fix (3 -patches):
http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commit;h=674db1344443204b6ce3293f2df8fd1b7665deea
http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commit;h=df71c9cfceea801e7e26e2c74241758ef9c042e5
http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commit;h=4b1bfb7d2d125af6653d6c2305356b2677f79dc6

> With the patch the oops is gone, but after a few hours it fails with:
> 
> [30971.764840] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0x07 failed for offset 0x0438 with error -71.

Looks there is something wrong at USB bus. Perhaps this could be debugged
using CONFIG_USB_DEBUG and friends. Eventually look at vendor driver to
check if it does not do some quirks regarding usb bus could help.

> [32048.962920] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [32048.970801] hostapd         D c02d85e0     0  1499      1 0x00000000
> [32048.977234] [<c02d85e0>] (schedule+0x478/0x4e8) from [<c02d9370>] (__mutex_lock_slowpath+0x64/0x88)
> [32048.986352] [<c02d9370>] (__mutex_lock_slowpath+0x64/0x88) from [<bf378f5c>] (rt2x00usb_vendor_request_buff+0x24/0xb8 [rt2x00usb])
> [32048.998185] [<bf378f5c>] (rt2x00usb_vendor_request_buff+0x24/0xb8 [rt2x00usb]) from [<bf38d034>] (rt2x00usb_register_read+0x34/0x44 [rt2800usb])
> [32049.011243] [<bf38d034>] (rt2x00usb_register_read+0x34/0x44 [rt2800usb]) from [<bf381d74>] (rt2800_config_shared_key+0xc4/0x11c [rt2800lib])
> [32049.023958] [<bf381d74>] (rt2800_config_shared_key+0xc4/0x11c [rt2800lib]) from [<bf36aac0>] (rt2x00mac_set_key+0x138/0x14c [rt2x00lib])
> [32049.036410] [<bf36aac0>] (rt2x00mac_set_key+0x138/0x14c [rt2x00lib]) from [<bf34379c>] (ieee80211_key_disable_hw_accel+0x80/0xd0 [mac80211])
> [32049.049221] [<bf34379c>] (ieee80211_key_disable_hw_accel+0x80/0xd0 [mac80211]) from [<bf343810>] (__ieee80211_key_destroy+0x24/0x6c [mac80211])
> [32049.062285] [<bf343810>] (__ieee80211_key_destroy+0x24/0x6c [mac80211]) from [<bf343bf4>] (ieee80211_key_link+0x10c/0x134 [mac80211])
> [32049.074471] [<bf343bf4>] (ieee80211_key_link+0x10c/0x134 [mac80211]) from [<bf33c3f8>] (ieee80211_add_key+0x104/0x130 [mac80211])
> [32049.086392] [<bf33c3f8>] (ieee80211_add_key+0x104/0x130 [mac80211]) from [<bf306cc8>] (nl80211_new_key+0xec/0x110 [cfg80211])
> [32049.097834] [<bf306cc8>] (nl80211_new_key+0xec/0x110 [cfg80211]) from [<c027542c>] (genl_rcv_msg+0x1bc/0x204)

As workaround I would try nohwcrypt module option.

Stanislaw
