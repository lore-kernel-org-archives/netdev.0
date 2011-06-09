From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 10/14] netvm: Set PF_MEMALLOC as appropriate during SKB processing
Date: Thu, 9 Jun 2011 12:21:31 +0200
Message-ID: <BANLkTimUE9yb-DegdUk0BbbOGWoUhEBrqw@mail.gmail.com>
References: <1307606573-24704-1-git-send-email-mgorman@suse.de> <1307606573-24704-11-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1307606573-24704-11-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

2011/6/9 Mel Gorman <mgorman@suse.de>:
[...]
> +/*
> + * Limit which protocols can use the PFMEMALLOC reserves to those that a=
re
> + * expected to be used for communication with swap.
> + */
> +static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 switch (skb->protocol) {
> + =A0 =A0 =A0 case __constant_htons(ETH_P_ARP):
> + =A0 =A0 =A0 case __constant_htons(ETH_P_IP):
> + =A0 =A0 =A0 case __constant_htons(ETH_P_IPV6):
> + =A0 =A0 =A0 case __constant_htons(ETH_P_8021Q):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 }
> +}

This is not needed and wrong. Whatever list there will be, it's going
to always miss some obscure setup (or not that obscure, like
ATAoverEthernet).

Best Regards,
Micha=B3 Miros=B3aw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
