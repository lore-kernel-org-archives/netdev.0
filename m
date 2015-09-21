From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net-next 1/2] ipv4: L3 hash-based multipath
Date: Mon, 21 Sep 2015 10:52:13 -0600
Message-ID: <560035BD.6090908@cumulusnetworks.com>
References: <1442348993-3023-1-git-send-email-pch@ordbogen.com>
 <1442348993-3023-2-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?UTF-8?Q?Peter_N=c3=b8rlund?= <pch@ordbogen.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32768 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbbIUQwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 12:52:08 -0400
Received: by pacex6 with SMTP id ex6so121369616pac.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 09:52:08 -0700 (PDT)
In-Reply-To: <1442348993-3023-2-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/15 2:29 PM, Peter N=C3=B8rlund wrote:
> @@ -1094,8 +1142,15 @@ struct fib_info *fib_create_info(struct fib_co=
nfig *cfg)
>
>   	change_nexthops(fi) {
>   		fib_info_update_nh_saddr(net, nexthop_nh);
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +		fi->fib_weight +=3D nexthop_nh->nh_weight;
> +#endif
>   	} endfor_nexthops(fi)
>
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +	fib_rebalance(fi);
> +#endif

The ifdefs everywhere make this harder to read. Just have a second=20
definition above for fib_rebalance(fi) when CONFIG_IP_ROUTE_MULTIPATH i=
s=20
not defined.

Similarly an inlined macro of fi->fib_weight that compiles out if=20
CONFIG_IP_ROUTE_MULTIPATH is not defined.

David
