From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ath9k_htc: add adaptive usb receive flow control to repair soft lockup with monitor mode
Date: Wed, 11 Feb 2015 11:20:52 +0200
Message-ID: <87oap0n6rv.fsf@kamboji.qca.qualcomm.com>
References: <1423506672-6686-1-git-send-email-yuweizheng@139.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, ath9k-devel@qca.qualcomm.com,
	netdev@vger.kernel.org, zhengyuwei@360.cn
To: Yuwei Zheng <yuweizheng@139.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423506672-6686-1-git-send-email-yuweizheng@139.com> (Yuwei
	Zheng's message of "Tue, 10 Feb 2015 02:31:12 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yuwei Zheng <yuweizheng@139.com> writes:

> The ath9k_hif_usb_rx_cb function excute on  the interrupt context, and ath9k_rx_tasklet excute
> on the soft irq context. In other words, the ath9k_hif_usb_rx_cb have more chance to excute than
> ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive list is always full,
> and the do {}while(true) loop will not be break. The kernel get a soft lockup panic. 
>  
> [59011.007210] BUG: soft lockup - CPU#0 stuck for 23s!
> [kworker/0:0:30609]
> [59011.030560] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100
> [59013.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100
> [59013.858522] Kernel panic - not syncing: softlockup: hung tasks
>  
> [59014.038891] Exception stack(0xdf4bbc38 to 0xdf4bbc80)
> [59014.046834] bc20:                                                       de57b950 60000113
> [59014.059579] bc40: 00000000 bb32bb32 60000113 de57b948 de57b500 dc7bb440 df4bbcd0 00000000
> [59014.072337] bc60: de57b950 60000113 df4bbcd0 df4bbc80 c04c259d c04c25a0 60000133 ffffffff
> [59014.085233] [<c04c28db>] (__irq_svc+0x3b/0x5c) from [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10)
> [59014.100437] [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10) from [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc])
> [59014.118267] [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc]) from [<c0036d23>] (tasklet_action+0x3b/0x98)
> [59014.134132] [<c0036d23>] (tasklet_action+0x3b/0x98) from [<c0036709>] (__do_softirq+0x99/0x16c)
> [59014.147784] [<c0036709>] (__do_softirq+0x99/0x16c) from [<c00369f7>] (irq_exit+0x5b/0x5c)
> [59014.160653] [<c00369f7>] (irq_exit+0x5b/0x5c) from [<c000cfc3>] (handle_IRQ+0x37/0x78)
> [59014.173124] [<c000cfc3>] (handle_IRQ+0x37/0x78) from [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68)
> [59014.187225] [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68) from [<c04c28db>](__irq_svc+0x3b/0x5c)
>  
> This bug can be see with low performance board, such as uniprocessor beagle bone board. Add some debug message in the ath9k_hif_usb_rx_cb
> function may trigger this bug quickly.
>  
> Signed-off-by: Yuwei Zheng <yuweizheng@139.com>

The word wrapping is still wrong, please limit the line length to 72
chars or so. This is the second time I'm mentioning that. Also add v2,
v3 and so on when you send new versions of the patch, otherwise I will
not know what version I should use. And even better if you add a
changelog after "---" line.

Documentation/SubmittingPatches should tell you all this.

-- 
Kalle Valo
