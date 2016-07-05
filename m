From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2, 1/3] mwifiex: add a cfg80211 .get_tx_power operation callback
Date: Tue,  5 Jul 2016 13:29:47 +0000 (UTC)
Message-ID: <20160705132947.D4B4060F78@smtp.codeaurora.org>
References: <1465232558-31678-2-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Julian Calaby <julian.calaby@gmail.com>,
	Shengzhen Li <szli@marvell.com>,
	Enric Balletbo i Serra <enric.balletbo@collabora.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465232558-31678-2-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Javier Martinez Canillas <javier@osg.samsung.com> wrote:
> The mwifiex driver implements a cfg80211 .set_tx_power operation handler
> but doesn't have the inverse .get_tx_power callback.
> 
> This not only has the effect that the Tx power can't be reported to user
> space tools such as iwconfig and iwlist but also that the wireless core
> prints a warning when a new wiphy is created due an cfg80211 operation
> being implemented without its counterpart.
> 
> After this patch, the Tx power is properly reported to user-space tools:
> 
> $ iwlist mlan0 txpower
> mlan0     unknown transmit-power information.
> 
>           Current Tx-Power=13 dBm       (19 mW)
> 
> and also the following warning isn't shown anymore on the driver probe:
> 
> WARNING: CPU: 3 PID: 127 at net/wireless/core.c:366 wiphy_new_nm+0x66c/0x6ac
> Modules linked in: mwifiex_sdio mwifiex
> CPU: 3 PID: 127 Comm: kworker/3:1 Tainted: G        W       4.7.0-rc1-next-20160531-00006-g569df5b983f3
> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
> Workqueue: events request_firmware_work_func
> [<c010e1ac>] (unwind_backtrace) from [<c010af38>] (show_stack+0x10/0x14)
> [<c010af38>] (show_stack) from [<c0323b9c>] (dump_stack+0x88/0x9c)
> [<c0323b9c>] (dump_stack) from [<c011a828>] (__warn+0xe8/0x100)
> [<c011a828>] (__warn) from [<c011a8f0>] (warn_slowpath_null+0x20/0x28)
> [<c011a8f0>] (warn_slowpath_null) from [<c06a42d4>] (wiphy_new_nm+0x66c/0x6ac)
> [<c06a42d4>] (wiphy_new_nm) from [<bf1c24cc>] (mwifiex_register_cfg80211+0x28/0x3f0 [mwifiex])
> [<bf1c24cc>] (mwifiex_register_cfg80211 [mwifiex]) from [<bf1a0018>] (mwifiex_fw_dpc+0x2b0/0x474 [mwifiex])
> [<bf1a0018>] (mwifiex_fw_dpc [mwifiex]) from [<c040eb74>] (request_firmware_work_func+0x30/0x58)
> [<c040eb74>] (request_firmware_work_func) from [<c012fe90>] (process_one_work+0x124/0x338)
> [<c012fe90>] (process_one_work) from [<c01300dc>] (worker_thread+0x38/0x4d4)
> [<c01300dc>] (worker_thread) from [<c01353b8>] (kthread+0xdc/0xf4)
> [<c01353b8>] (kthread) from [<c0107978>] (ret_from_fork+0x14/0x3c)
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> Tested-by: Enric Balletbo i Serra <enric.balletbo@collabora.com>

Thanks, 2 patches applied to wireless-drivers-next.git:

7d54bacadce1 mwifiex: add a cfg80211 .get_tx_power operation callback
3ee712857958 mwifiex: add get_antenna support for cfg80211

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9158855/
