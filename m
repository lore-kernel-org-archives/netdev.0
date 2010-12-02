From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install time
Date: Thu, 2 Dec 2010 19:29:53 +0800
Message-ID: <AANLkTimZgiYi3KE7DC8DMWEzgSx7+cUaOurEHSo864AP@mail.gmail.com>
References: <1291227893.2856.1039.camel@edumazet-laptop> <20101201.104450.183053379.davem@davemloft.net>
 <1291232937.2856.1042.camel@edumazet-laptop> <20101201.122312.229751364.davem@davemloft.net>
 <1291236342.2856.1057.camel@edumazet-laptop> <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
 <1291272384.2856.1074.camel@edumazet-laptop> <AANLkTim8+9AA61HwcCQp3p7cSjzaTqerdd4Wtm-28kAt@mail.gmail.com>
 <1291280000.2871.16.camel@edumazet-laptop> <1291280402.2871.20.camel@edumazet-laptop>
 <AANLkTikQOY7Nh7XOFT9wXDYpn1faVS9xH2Y-x67hiu7S@mail.gmail.com>
 <1291283693.2871.48.camel@edumazet-laptop> <AANLkTikkeQNzTMs_AifJFFU3oEKAmMBaCO9PCRWLRTSo@mail.gmail.com>
 <1291288548.2871.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50419 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146Ab0LBLaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 06:30:14 -0500
Received: by fxm20 with SMTP id 20so1024334fxm.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 03:30:13 -0800 (PST)
In-Reply-To: <1291288548.2871.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 2, 2010 at 7:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Their scratch memory is not on stack but part of the filter, so no
> security problem (You can only read previous values of scratch registers
> written by your own filter on handling a previous packet.)
>

The code I checked is the newest in SVN. The scratch memory is really on stack.

/*
 * Execute the filter program starting at pc on the packet p
 * wirelen is the length of the original packet
 * buflen is the amount of data present
 */
u_int
bpf_filter(const struct bpf_insn *pc, u_char *p, u_int wirelen, u_int buflen)
{
        u_int32_t A = 0, X = 0;
        bpf_u_int32 k;
        u_int32_t mem[BPF_MEMWORDS];



-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
