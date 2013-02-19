From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v2] net: fec: Fix the disabling of RX interrupt
Date: Tue, 19 Feb 2013 11:27:48 +0800
Message-ID: <CAHrpEqQUHj6nNDSGVTGPuGJynAS7zG4LwQkHcMfSxrO9-oeTrQ@mail.gmail.com>
References: <1361217895-17143-1-git-send-email-fabio.estevam@freescale.com>
	<CAHrpEqRpjQuADCzXyF4+Q359TjovXDdNJaurGKin0-0Ta2+kZg@mail.gmail.com>
	<CAOMZO5CRQeuF_ERZ0v2uocuADXRWscKLN0KqdDHfu+0Ub2MEhw@mail.gmail.com>
	<CAHrpEqQ-hoR1W2w8QXP4zF=9C6dDv2juWzq9dzHjKZ+emdbK1g@mail.gmail.com>
	<CAOMZO5DBuswBA92s4gRLiRO9ZyX7mmd+27-4619ms322Rirrow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fabio Estevam <fabio.estevam@freescale.com>, davem@davemloft.net,
	Frank.Li@freescale.com, shawn.guo@linaro.org, marex@denx.de,
	s.hauer@pengutronix.de, netdev@vger.kernel.org
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:63297 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758115Ab3BSD1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 22:27:50 -0500
Received: by mail-wi0-f169.google.com with SMTP id l13so4520148wie.0
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 19:27:48 -0800 (PST)
In-Reply-To: <CAOMZO5DBuswBA92s4gRLiRO9ZyX7mmd+27-4619ms322Rirrow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/19 Fabio Estevam <festevam@gmail.com>:
> On Mon, Feb 18, 2013 at 11:47 PM, Frank Li <lznuaa@gmail.com> wrote:
>
>> This is similar with my first implement.
>
> I checked your original implementation and
> spin_lock_irqsave/spin_unlock_irqrestore was very far apart.
>
>> It just protect irq and init function. Many place write FEC_IMASK directly.
>
> Yes, but the main issue with current code is that it does not clear
> the only rx irq as it should.

The key is Read OR and write need lock.
I try reduce FEC lock.

FEC_IMASK should be two state,
one is FEC_DEFAULT_IMASK, the other is FEC_RX_DISABLED_IMASK.
FEC_RX_DISABLED_IMASK is equal as clean rx irq only.

I will found mx53 to found the real root cause

>
>> I think this issue was caused by enable irq before register irq handler.
>> writel(0, fep->hwp + FEC_IMASK) should fix mx53's problem.
>
> No, it does not solve the issue.
>
> I don't have a mx6q board handy. If you could try this patch and let
> me know if you see any deadlock, it would be nice.
>
> Thanks,
>
> Fabio Estevam
