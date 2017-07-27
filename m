From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [net] wl1251: add a missing spin_lock_init()
Date: Thu, 27 Jul 2017 10:59:59 +0000 (UTC)
Message-ID: <20170727105959.4B7B0607A3@smtp.codeaurora.org>
References: <1499378437-4971-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pavel@ucw.cz,
        linux-wireless@vger.kernel.org,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55694 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdG0K77 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:59:59 -0400
In-Reply-To: <1499378437-4971-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:

> This fixes the following kernel warning:
> 
>   [ 5668.771453] BUG: spinlock bad magic on CPU#0, kworker/u2:3/9745
>   [ 5668.771850]  lock: 0xce63ef20, .magic: 00000000, .owner: <none>/-1,
>   .owner_cpu: 0
>   [ 5668.772277] CPU: 0 PID: 9745 Comm: kworker/u2:3 Tainted: G        W
>   4.12.0-03002-gec979a4-dirty #40
>   [ 5668.772796] Hardware name: Nokia RX-51 board
>   [ 5668.773071] Workqueue: phy1 wl1251_irq_work
>   [ 5668.773345] [<c010c9e4>] (unwind_backtrace) from [<c010a274>]
>   (show_stack+0x10/0x14)
>   [ 5668.773803] [<c010a274>] (show_stack) from [<c01545a4>]
>   (do_raw_spin_lock+0x6c/0xa0)
>   [ 5668.774230] [<c01545a4>] (do_raw_spin_lock) from [<c06ca578>]
>   (_raw_spin_lock_irqsave+0x10/0x18)
>   [ 5668.774658] [<c06ca578>] (_raw_spin_lock_irqsave) from [<c048c010>]
>   (wl1251_op_tx+0x38/0x5c)
>   [ 5668.775115] [<c048c010>] (wl1251_op_tx) from [<c06a12e8>]
>   (ieee80211_tx_frags+0x188/0x1c0)
>   [ 5668.775543] [<c06a12e8>] (ieee80211_tx_frags) from [<c06a138c>]
>   (__ieee80211_tx+0x6c/0x130)
>   [ 5668.775970] [<c06a138c>] (__ieee80211_tx) from [<c06a3dbc>]
>   (ieee80211_tx+0xdc/0x104)
>   [ 5668.776367] [<c06a3dbc>] (ieee80211_tx) from [<c06a4af0>]
>   (__ieee80211_subif_start_xmit+0x454/0x8c8)
>   [ 5668.776824] [<c06a4af0>] (__ieee80211_subif_start_xmit) from
>   [<c06a4f94>] (ieee80211_subif_start_xmit+0x30/0x2fc)
>   [ 5668.777343] [<c06a4f94>] (ieee80211_subif_start_xmit) from
>   [<c0578848>] (dev_hard_start_xmit+0x80/0x118)
>   ...
> 
> by adding the missing spin_lock_init().
> 
> Reported-by: Pavel Machek <pavel@ucw.cz>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Acked-by: Pavel Machek <pavel@ucw.cz>

Patch applied to wireless-drivers-next.git, thanks.

6e9aae179f29 wl1251: add a missing spin_lock_init()

-- 
https://patchwork.kernel.org/patch/9829083/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
