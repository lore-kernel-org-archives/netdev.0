From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH v2 0/3] mwifiex: add .get_tx_power and .get_antenna cfg80211 operations
Date: Mon,  6 Jun 2016 13:02:35 -0400
Message-ID: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Shengzhen Li <szli@marvell.com>,
	Enric Balletbo i Serra <enric.balletbo@collabora.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Since commit de3bb771f471 ("cfg80211: add more warnings for inconsistent
ops") the wireless core warns if a driver implements a cfg80211 callback
but doesn't implements the inverse operation. The mwifiex driver has two
set operations defined without the get counterpat so warnings are shown:

    WARNING: CPU: 3 PID: 127 at net/wireless/core.c:366 wiphy_new_nm+0x66c/0x6ac
    Modules linked in: mwifiex_sdio mwifiex
    CPU: 3 PID: 127 Comm: kworker/3:1 Tainted: G        W       4.7.0-rc1-next-20160531-00006-g569df5b983f3
    Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
    Workqueue: events request_firmware_work_func
    [<c010e1ac>] (unwind_backtrace) from [<c010af38>] (show_stack+0x10/0x14)
    [<c010af38>] (show_stack) from [<c0323b9c>] (dump_stack+0x88/0x9c)
    [<c0323b9c>] (dump_stack) from [<c011a828>] (__warn+0xe8/0x100)
    [<c011a828>] (__warn) from [<c011a8f0>] (warn_slowpath_null+0x20/0x28)
    [<c011a8f0>] (warn_slowpath_null) from [<c06a42d4>] (wiphy_new_nm+0x66c/0x6ac)
    [<c06a42d4>] (wiphy_new_nm) from [<bf1c24cc>] (mwifiex_register_cfg80211+0x28/0x3f0 [mwifiex])
    [<bf1c24cc>] (mwifiex_register_cfg80211 [mwifiex]) from [<bf1a0018>] (mwifiex_fw_dpc+0x2b0/0x474 [mwifiex])
    [<bf1a0018>] (mwifiex_fw_dpc [mwifiex]) from [<c040eb74>] (request_firmware_work_func+0x30/0x58)
    [<c040eb74>] (request_firmware_work_func) from [<c012fe90>] (process_one_work+0x124/0x338)
    [<c012fe90>] (process_one_work) from [<c01300dc>] (worker_thread+0x38/0x4d4)
    [<c01300dc>] (worker_thread) from [<c01353b8>] (kthread+0xdc/0xf4)
    [<c01353b8>] (kthread) from [<c0107978>] (ret_from_fork+0x14/0x3c)

This patch series fixes the warnings by implementing callbacks for the
missing get operations.

Since the first version was posted [0], Amitkumar Karwar from Marvell
provided me their patches that adds the same. The .get_tx_power patch was
very similar to mine. So I kept my patch and added the delta as a follow
up patch but discarded my .get_antenna patch since the one provided by
Amitkumar queries the firmware so is the correct approach.

Patches were tested on an Exynos5800 Chromebook that has a mwifiex chip.

Changes since v1:
- Drop patch that reports antenna cached values and use Marvell's patch
  instead.
- Add patch that moves the .get_tx_power() logic to sta_ioctl.c file.

[0]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1160119.html

Best regards,
Javier


Javier Martinez Canillas (1):
  mwifiex: add a cfg80211 .get_tx_power operation callback

Shengzhen Li (2):
  mwifiex: move .get_tx_power logic to station ioctl file
  mwifiex: add get_antenna support for cfg80211

 drivers/net/wireless/marvell/mwifiex/cfg80211.c    | 32 ++++++++++++++
 drivers/net/wireless/marvell/mwifiex/fw.h          |  3 ++
 drivers/net/wireless/marvell/mwifiex/init.c        |  2 +
 drivers/net/wireless/marvell/mwifiex/main.h        |  4 ++
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     | 50 +++++++++++++++-------
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c | 10 +++--
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   | 18 ++++++++
 7 files changed, 100 insertions(+), 19 deletions(-)

-- 
2.5.5
