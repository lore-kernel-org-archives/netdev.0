From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [ath9k-devel] [PATCH] Repair soft lockup with monitor mode of ath9k_htc card
Date: Thu, 29 Jan 2015 13:01:19 +0200
Message-ID: <874mr93l6o.fsf@kamboji.qca.qualcomm.com>
References: <1422504583-17839-1-git-send-email-zhengyuwei@360.cn>
	<54CA10DB.3070903@rempel-privat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zhengyuwei@360.cn, linux-kernel@vger.kernel.org,
	ath9k-devel@venema.h4ckr.net, linux-wireless@vger.kernel.org,
	ath9k-devel@qca.qualcomm.com, netdev@vger.kernel.org
To: Oleksij Rempel <linux@rempel-privat.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CA10DB.3070903@rempel-privat.de> (Oleksij Rempel's message of
	"Thu, 29 Jan 2015 11:52:11 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oleksij Rempel <linux@rempel-privat.de> writes:

> Am 29.01.2015 um 05:09 schrieb zhengyuwei@360.cn:
>> From: Yuwei Zheng <zhengyuwei@360.cn>
>> 
>> In the environment with heavy wifi traffic, set the ar9271 into monitor mode, will
>> trigger a deadloop panic. 
>> 
>> The ath9k_hif_usb_rx_cb function excute on  the interrupt context, and ath9k_rx_tasklet excute
>> on the soft irq context. In other words, the ath9k_hif_usb_rx_cb have more chance to excute than
>> ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive list is always full,
>> and the do {}while(true) loop will not be break. The kernel get a soft lockup panic.  
>>   
>> [59011.007210] BUG: soft lockup - CPU#0 stuck for 23s! 
>> [kworker/0:0:30609]
>> [59011.030560] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100
>> [59013.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100
>> [59013.858522] Kernel panic - not syncing: softlockup: hung tasks
>> 
>> [59014.038891] Exception stack(0xdf4bbc38 to 0xdf4bbc80)
>> [59014.046834] bc20:                                                       de57b950 60000113
>> [59014.059579] bc40: 00000000 bb32bb32 60000113 de57b948 de57b500 dc7bb440 df4bbcd0 00000000
>> [59014.072337] bc60: de57b950 60000113 df4bbcd0 df4bbc80 c04c259d c04c25a0 60000133 ffffffff
>> [59014.085233] [<c04c28db>] (__irq_svc+0x3b/0x5c) from [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10)
>> [59014.100437] [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10) from [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc])
>> [59014.118267] [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc]) from [<c0036d23>] (tasklet_action+0x3b/0x98)
>> [59014.134132] [<c0036d23>] (tasklet_action+0x3b/0x98) from [<c0036709>] (__do_softirq+0x99/0x16c)
>> [59014.147784] [<c0036709>] (__do_softirq+0x99/0x16c) from [<c00369f7>] (irq_exit+0x5b/0x5c)
>> [59014.160653] [<c00369f7>] (irq_exit+0x5b/0x5c) from [<c000cfc3>] (handle_IRQ+0x37/0x78)
>> [59014.173124] [<c000cfc3>] (handle_IRQ+0x37/0x78) from [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68)
>> [59014.187225] [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68) from [<c04c28db>](__irq_svc+0x3b/0x5c)
>> 
>> This bug can be see with low performance board, such as uniprocessor beagle bone board.
>> Signed-off-by: Yuwei Zheng <zhengyuwei@360.cn>
>> 
>> ---
>>  drivers/net/wireless/ath/ath9k/hif_usb.c       | 53 ++++++++++++++++++++++----
>>  drivers/net/wireless/ath/ath9k/hif_usb.h       |  5 +++
>>  drivers/net/wireless/ath/ath9k/htc.h           | 13 +++++++
>>  drivers/net/wireless/ath/ath9k/htc_drv_debug.c | 49 ++++++++++++++++++++++++
>>  drivers/net/wireless/ath/ath9k/htc_drv_txrx.c  | 26 +++++++++++++
>>  5 files changed, 139 insertions(+), 7 deletions(-)
>
> First of all, thank you for you work! :D
>
> Please run ./scripts/checkpatch.pl yourpatch_path
> i get:
> total: 139 errors, 12 warnings, 2 checks, 231 lines checked

Also please add "ath9k_htc:" prefix to the title.

-- 
Kalle Valo
