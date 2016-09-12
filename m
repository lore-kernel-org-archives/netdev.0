From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 23/26] sh_eth: constify local structures
Date: Mon, 12 Sep 2016 11:43:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121137430.3049@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr> <1473599168-30561-24-git-send-email-Julia.Lawall@lip6.fr> <cb443416-4fb9-5593-2529-66211299c9a8@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <cb443416-4fb9-5593-2529-66211299c9a8@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 11 Sep 2016, Sergei Shtylyov wrote:

> On 09/11/2016 04:06 PM, Julia Lawall wrote:
> > For structure types defined in the same file or local header files, find
> > top-level static structure declarations that have the following
> > properties:
> > 1. Never reassigned.
>
>   Really?
>
> > 2. Address never taken
>
>   Really?

OK, I see the problem.  The code has, eg:

{ "sh7724-ether", (kernel_ulong_t)&sh7724_data }

Coccinelle doesn't know anything about kernel_ulong_t, so it assumes that
it is an identifier, and that the whole expression is a bit and, rather
than an address computation.  And at the same time, the cast causes the
compiler to discard the const annotation, so it doesn't complain either.

I can update the rule to avoid this case, since taking a bit and on the
address of a top-level structure is not likely to be useful, and I will
check whether any of the other patches are affected by this issue.

Thanks for the report.

julia


>
> > 3. Not passed to a top-level macro call
> > 4. No pointer or array-typed field passed to a function or stored in a
> > variable.
> > Declare structures having all of these properties as const.
> >
> > Done using Coccinelle.
> > Based on a suggestion by Joe Perches <joe@perches.com>.
> >
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
>    NAK, see sh_eth_set_default_cpu_data().
>
> MBR, Sergei
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
