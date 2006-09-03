From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: BUG in bcm32xx-d80211: sleeping function called with irq's disabled
Date: Sat, 02 Sep 2006 22:42:58 -0500
Message-ID: <44FA4F42.1020302@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The latest git pull from wireless-dev (g7844a579) is calling a sleeping function with irq's
disabled. The kernel is a UP version with preemption disabled. The dump is as follows:

kernel: bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 4, MAC: 00:06:25:40:6f:03)
kernel: bcm43xx_d80211: PHY connected
kernel: BUG: sleeping function called from invalid context at kernel/mutex.c:86
kernel: in_atomic():0, irqs_disabled():1
kernel:  [<c0103b67>] show_trace_log_lvl+0x197/0x1c0
kernel:  [<c0104f7b>] show_trace+0x1b/0x20
kernel:  [<c0104fa6>] dump_stack+0x26/0x30
kernel:  [<c0113382>] __might_sleep+0xa2/0xc0
kernel:  [<c031347d>] mutex_lock+0x1d/0x30
kernel:  [<e791c72a>] ssb_core_is_enabled+0x1a/0x50 [ssb]
kernel:  [<e7b2797d>] bcm43xx_wireless_core_reset+0x1d/0xc0 [bcm43xx_d80211]
kernel:  [<e7b3bd74>] bcm43xx_phy_calibrate+0x74/0xe0 [bcm43xx_d80211]
kernel:  [<e7b2bbdb>] wireless_core_up+0x5b/0x700 [bcm43xx_d80211]
kernel:  [<e7b2c98a>] bcm43xx_select_wireless_core+0x22a/0x8c0 [bcm43xx_d80211]
kernel:  [<e7b2d0a4>] bcm43xx_init_board+0x84/0xb0 [bcm43xx_d80211]
kernel:  [<e7b2d1a6>] bcm43xx_net_open+0x16/0x20 [bcm43xx_d80211]
kernel:  [<e79481c5>] ieee80211_open+0x175/0x360 [80211]
kernel:  [<c02c2233>] dev_open+0x43/0x90
kernel:  [<c02c11c5>] dev_change_flags+0x55/0x130
kernel:  [<c03006af>] devinet_ioctl+0x65f/0x6d0
kernel:  [<c0300a18>] inet_ioctl+0x88/0xb0
kernel:  [<c02b64cb>] sock_ioctl+0xbb/0x260
kernel:  [<c01718db>] do_ioctl+0x2b/0x80
kernel:  [<c0171981>] vfs_ioctl+0x51/0x290
kernel:  [<c0171c01>] sys_ioctl+0x41/0x60
kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:  [<b7f35410>] 0xb7f35410
kernel:  [<c0104f7b>] show_trace+0x1b/0x20
kernel:  [<c0104fa6>] dump_stack+0x26/0x30
kernel:  [<c0113382>] __might_sleep+0xa2/0xc0
kernel:  [<c031347d>] mutex_lock+0x1d/0x30
kernel:  [<e791c72a>] ssb_core_is_enabled+0x1a/0x50 [ssb]
kernel:  [<e7b2797d>] bcm43xx_wireless_core_reset+0x1d/0xc0 [bcm43xx_d80211]
kernel:  [<e7b3bd74>] bcm43xx_phy_calibrate+0x74/0xe0 [bcm43xx_d80211]
kernel:  [<e7b2bbdb>] wireless_core_up+0x5b/0x700 [bcm43xx_d80211]
kernel:  [<e7b2c98a>] bcm43xx_select_wireless_core+0x22a/0x8c0 [bcm43xx_d80211]
kernel:  [<e7b2d0a4>] bcm43xx_init_board+0x84/0xb0 [bcm43xx_d80211]
kernel:  [<e7b2d1a6>] bcm43xx_net_open+0x16/0x20 [bcm43xx_d80211]
kernel:  [<e79481c5>] ieee80211_open+0x175/0x360 [80211]
kernel:  [<c02c2233>] dev_open+0x43/0x90
kernel:  [<c02c11c5>] dev_change_flags+0x55/0x130
kernel:  [<c03006af>] devinet_ioctl+0x65f/0x6d0
kernel:  [<c0300a18>] inet_ioctl+0x88/0xb0
kernel:  [<c02b64cb>] sock_ioctl+0xbb/0x260
kernel:  [<c01718db>] do_ioctl+0x2b/0x80
kernel:  [<c0171981>] vfs_ioctl+0x51/0x290
kernel:  [<c0171c01>] sys_ioctl+0x41/0x60
kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel: bcm43xx_d80211: PHY disconnected
