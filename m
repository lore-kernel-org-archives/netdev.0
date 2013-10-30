From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Tue, 29 Oct 2013 20:50:08 -0700
Message-ID: <CAM_iQpXzJOxZ3MFNthKw5ye=WcxDWbiPaHuL=pHMz7D1R4nJ+w@mail.gmail.com>
References: <1383084998-22673-1-git-send-email-tdmackey@booleanhaiku.com>
	<20131029.224227.1700872646112764527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: tdmackey@booleanhaiku.com, mchan@broadcom.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131029.224227.1700872646112764527.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 7:42 PM, David Miller <davem@davemloft.net> wrote:
> From: David Mackey <tdmackey@booleanhaiku.com>
> Date: Tue, 29 Oct 2013 15:16:38 -0700
>
>> Using dev_kfree_skb_any() will resolve the below issue when a
>> netconsole message is transmitted in an irq.
>  ...
>> Signed-off-by: David Mackey <tdmackey@booleanhaiku.com>
>
> This is absolutely not the correct fix.
>
> The netpoll facility must invoke ->poll() in an environment which
> is compatible, locking and interrupt/soft-interrupt wise, as that
> in which it is normally called.
>

Normally ->poll() is called in softirq context, while netpoll could
be called in any context depending on its caller.

Also, netpoll disables IRQ for tx, which is another difference.
