From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: kernel BUG at /usr/src/linux-2.6.25/kernel/workqueue.c:224! (r8169?)
Date: Mon, 21 Apr 2008 17:22:15 -0400
Message-ID: <76366b180804211422k33057607p586b5deed7849c07@mail.gmail.com>
References: <76366b180804201548g309ae6cci286ed6552f3cb71e@mail.gmail.com>
	 <76366b180804202016l19ac362cyb814781449f81e9a@mail.gmail.com>
	 <20080421203458.GA2931@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:56917 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538AbYDUVWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:22:17 -0400
Received: by an-out-0708.google.com with SMTP id d31so528837and.103
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 14:22:16 -0700 (PDT)
In-Reply-To: <20080421203458.GA2931@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois,

On this kernel CONFIG_R8169_NAPI is disabled, so that code would not
even be compiled in. Is NAPI stable enough that I should be using it
now? (It is still marked experimental)

Thanks,
-Andrew

On Mon, Apr 21, 2008 at 4:34 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Andrew Paprocki <andrew@ishiboo.com> :
>
> > I just received a similar bug on workqueue.c:223 while I was not doing
>  > anything with the card. These bugs seem to have increased with
>  > frequency when running under 2.6.25. It used to take me some time to
>  > cause a problem to appear under 2.6.24, but under 2.6.25 they appear
>  > very readily. I was actually not touching the machine at all when this
>  > appeared on the console:
>
>  Does the patch below decrease the frequency of the bug ?
>
>  diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>  index 3acfeea..6ee9db1 100644
>  --- a/drivers/net/r8169.c
>  +++ b/drivers/net/r8169.c
>  @@ -2398,8 +2398,6 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
>         rtl8169_irq_mask_and_ack(ioaddr);
>
>   #ifdef CONFIG_R8169_NAPI
>  -       tp->intr_mask = 0xffff;
>  -       RTL_W16(IntrMask, tp->intr_event);
>         napi_enable(&tp->napi);
>   #endif
>   }
>
>  --
>  Ueimor
>
>
