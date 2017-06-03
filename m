From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: stmmac: ensure jumbo_frm error return is correctly
 checked for -ve value
Date: Sat, 3 Jun 2017 18:53:36 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1706031847280.2014@hadrien>
References: <20170602145827.21151-1-colin.king@canonical.com> <CAHp75VeuumsZHDdue=n-2esyG7Q-6472JoYJ64U0+OQoC2psgQ@mail.gmail.com> <40331b09-5829-9041-f815-7f1426960bd8@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:5708 "EHLO
        mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750991AbdFCQxk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 12:53:40 -0400
In-Reply-To: <40331b09-5829-9041-f815-7f1426960bd8@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 3 Jun 2017, Colin Ian King wrote:

> On 03/06/17 16:55, Andy Shevchenko wrote:
> > On Fri, Jun 2, 2017 at 5:58 PM, Colin King <colin.king@canonical.com> wrote:
> >> The current comparison of entry < 0 will never be true since entry is an
> >> unsigned integer. Cast entry to an int to ensure -ve error return values
> >> from the call to jumbo_frm are correctly being caught.
> >
> >>         if (unlikely(is_jumbo) && likely(priv->synopsys_id <
> >>                                          DWMAC_CORE_4_00)) {
> >>                 entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
> >> -               if (unlikely(entry < 0))
> >> +               if (unlikely((int)entry < 0))
> >
> > It feels like a hiding some other issue.
> >
>
> The alternative is:
>
> 		int rc = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
> 		if (unlikely(rc < 0))
> 			goto dma_map_err;
>
> 		entry = rc;
>
> however, that is effectively the same. The cast I'm using is a well used
> idiom in the kernel, it used in almost a hundred similar cases.
>
> git grep "< 0" | grep "(int)" | wc -l
> 95

Does entry really have to be unsigned?  The jumbo_frm function returns an
int, not an unsigned int, so it seems unpleasant to make it unsigned
prematurely just to put a cast afterwards.  The remaining computation
seems to involve only small numbers.

julia
