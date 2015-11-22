From: Shunqian Zheng <zhengsq@rock-chips.com>
Subject: [RFC PATCH v1] Trying to fix the stmmac memory leak during suspend/resume
Date: Sun, 22 Nov 2015 16:44:17 +0800
Message-ID: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
Cc: linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, dianders@google.com,
	ZhengShunQian <zhengsq@rock-chips.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ZhengShunQian <zhengsq@rock-chips.com>

When I run Suspend-to-Ram stress test on my Rockchip RK3288(SoC) board
that integrated stmmac ethernet, it always OOM after a few iterations,
usually 50 times is enough to reproduce.

Compiled kernel with KMEMLEAK feature, I got the logs as below:
unreferenced object 0xed89ac00 (size 192):
  comm "busybox", pid 79, jiffies 2251 (age 54.580s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 d1 ed 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<c05430dc>] kmemleak_alloc+0x44/0x78
    [<c012b198>] kmem_cache_alloc+0x1ac/0x264
    [<c0442134>] __build_skb+0x38/0x9c
    [<c0442350>] __netdev_alloc_skb+0xac/0x118
    [<c0335f8c>] init_dma_desc_rings+0xcc/0x474
    [<c0336f20>] stmmac_resume+0xc4/0x14c
    [<c033ed28>] stmmac_pltfr_resume+0x3c/0x40
    [<c02ed4dc>] platform_pm_resume+0x3c/0x50
    [<c02f7ad0>] dpm_run_callback+0x7c/0x160
    [<c02f7e14>] device_resume+0x174/0x1c0
    [<c02f9368>] dpm_resume+0x110/0x2cc
    [<c02f9830>] dpm_resume_end+0x1c/0x28
    [<c00646c0>] suspend_devices_and_enter+0x53c/0x6ec
    [<c0064ba4>] pm_suspend+0x334/0x478
    [<c0063110>] state_store+0xac/0xc8
    [<c0265228>] kobj_attr_store+0x1c/0x28

Actually I don't think I know net/stmmac good enough to fix this bug.
I really appreciate that the exports of net/stmmac can take over it if
you think it is a bug too.

ZhengShunQian (1):
  net: stmmac: Free rx_skbufs before realloc

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

-- 
1.9.1
