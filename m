From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Wed, 02 Mar 2011 12:37:15 +0100
Message-ID: <4D6E2BEB.50805@trash.net>
References: <118081298480841@web25.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Oleg A. Arkhangelsky" <sysoleg@yandex.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <118081298480841@web25.yandex.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 23.02.2011 18:07, schrieb "Oleg A. Arkhangelsky":
> Hello,
> 
> Got this panic yesterday:
> http://www.progtech.ru/~oleg/crash.txt
> 
> The offending instruction is:
> cmpb 54(%edx), %cl # <variable>.tuple.dst.protonum,
> 
> and here is the assembler code of net/ipv4/netfilter/nf_nat_core.c:
> http://www.progtech.ru/~oleg/nf_nat_core.s
> 
> Quick investigation lead me to conclusion that the problem is in
> return of same_src function:
> 
>         return (t->dst.protonum == tuple->dst.protonum &&
>                 t->src.u3.ip == tuple->src.u3.ip &&
>                 t->src.u.all == tuple->src.u.all);
> 
> So either t or tuple pointer is bad, but I don't understand how
> this can be.

I'm not sure myself, I'm guessing it has something to do with
reallocation of the NAT extension area. Please post your full
ruleset and any helpers in use.

> [2971152.752502] Pid: 0, comm: swapper Not tainted (2.6.32.25-pt #1)

Also please try whether the problem still happens with the current
kernel version.
