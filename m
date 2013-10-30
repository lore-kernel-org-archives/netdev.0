From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Wed, 30 Oct 2013 12:23:52 -0700
Message-ID: <CAM_iQpV6ufX5-OOrNQtsXH0_9itjU-FriOoutyKfDEWdg-irQw@mail.gmail.com>
References: <1383084998-22673-1-git-send-email-tdmackey@booleanhaiku.com>
	<20131029.224227.1700872646112764527.davem@davemloft.net>
	<CAM_iQpXzJOxZ3MFNthKw5ye=WcxDWbiPaHuL=pHMz7D1R4nJ+w@mail.gmail.com>
	<20131030.024003.1476890051483056287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: tdmackey@booleanhaiku.com, mchan@broadcom.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131030.024003.1476890051483056287.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 11:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 29 Oct 2013 20:50:08 -0700
>
>> Normally ->poll() is called in softirq context, while netpoll could
>> be called in any context depending on its caller.
>
> It still makes amends to make the execution context still looks
> "compatible" as far as locking et al. is concerned.

Adjusting netpoll code for IRQ context is much harder
than just calling dev_kfree_skb_any()...

What's more, we have similar change before:

commit ed79bab847d8e5a2986d8ff43c49c6fb8ee3265f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Oct 14 14:36:43 2009 +0000

    virtio_net: use dev_kfree_skb_any() in free_old_xmit_skbs()
