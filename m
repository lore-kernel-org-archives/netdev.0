From: Chris Caputo <ccaputo@alt.net>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Tue, 11 Oct 2016 03:57:52 +0000 (UTC)
Message-ID: <alpine.LNX.2.00.1610110353160.3698@nacho.alt.net>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
        <Pine.LNX.4.64.1610100627230.28174@nacho.alt.net>
        <CAML_gOeUOrt=-D3VHS2B3B_Q1F2-DAYK95Oxu4FEvfE43hjb3g@mail.gmail.com>
        <Pine.LNX.4.64.1610101818110.28174@nacho.alt.net>
        <CAML_gOeNcgH-26iL6W5GDf0Ke0Sbpe9MTSULTvTnuiR9Cj_ZLA@mail.gmail.com>
Reply-To: Chris Caputo <ccaputo-dated-1486526273.d9d440@alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vishwanath Pai <vpai@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        linux-kernel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOeNcgH-26iL6W5GDf0Ke0Sbpe9MTSULTvTnuiR9Cj_ZLA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Oct 2016, Liping Zhang wrote:
> Yes, thanks for clarifying this. There's a bug in kernel, can you try
> this patch:
> 
> diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
> index 018eed7..8c069b4 100644
> --- a/net/netfilter/xt_NFLOG.c
> +++ b/net/netfilter/xt_NFLOG.c
> @@ -32,6 +32,7 @@ nflog_tg(struct sk_buff *skb, const struct
> xt_action_param *par)
>         li.u.ulog.copy_len   = info->len;
>         li.u.ulog.group      = info->group;
>         li.u.ulog.qthreshold = info->threshold;
> +       li.u.ulog.flags      = 0;
> 
>         if (info->flags & XT_NFLOG_F_COPY_LEN)
>                 li.u.ulog.flags |= NF_LOG_F_COPY_LEN;

I have tested the above patch with 4.8.1, with and without nflog-size 
defined in an iptables configuration, and it works well.

The ulogd-2.0.5 segfaults no longer happen when nflog-size is not present 
in a target.

I recommend this fix.

Thanks,
Chris
