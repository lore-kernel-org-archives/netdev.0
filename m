From: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Information leak in llcp_sock_bind/llcp_raw_sock_bind
Date: Wed, 16 Dec 2015 19:59:48 +0100
Message-ID: <CACT4Y+YCkDLemqW_Ci6Hv418qWLP91kZSoXH8dvXYZbZbgSO1A@mail.gmail.com>
References: <CACT4Y+ZnZ2EcZwc6T5LZ1YR2zC8+6aFT_JFYb_LeegnB6tmESw@mail.gmail.com>
 <20151215.154851.2132284113916223057.davem@davemloft.net> <CACT4Y+a804iMbkA+kWdYfOPYGQz61ZCRVqKOdDBYtSM=FQ2cYQ@mail.gmail.com>
 <20151215.155856.467616191891653108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151215.155856.467616191891653108.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 9:58 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 15 Dec 2015 21:55:37 +0100
>
>> I've seen a kernel address at least in pptp_bind,
>
> We're not talking about pptp_bind.
>
> We're talking about llcp_{,raw}_sock_bind().
>
> If your hex dump doesn't show it, don't report anything unless you are
> absolutely sure via code inspection that there could be a leak.  And
> in that case make it perfectly clear exactly how that can happen.
>
> I am generally unimpressed with your reports half of the time,
> and just a small amount of extra effort would extraordinarily
> improve the quality of the things your post.
>
> Thanks.
>
>> So it is almost impossible to prove that a PC cannot be leaked.
>
> You can't show that anything is actually being leaked in this specific
> case, period.


I am a human and sometimes do mistakes.

In this case, I checked that the bind succeeds when I pass
sockaddrlen=0, which is suspicious and matches the behavior of pptp
case (not checking sockaddrlen at all). Then I looked at the code and
misread it, because it uses a different idiom from other cases I saw
(explicitly checking sockaddrlen value). Then I wrote a test program
and observed a varying, garbage-looking values returned from
getsockname. From that I concluded that there is an information leak.
This is wrong.

For the purpose of improvement of my reports, what are the other
reports you are not impressed with and why?

Thank you
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
