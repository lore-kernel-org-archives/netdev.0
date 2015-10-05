From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] Fixes: 0e884c7 ipv4: L3 hash-based multipath:
 tag
Date: Mon, 5 Oct 2015 15:23:10 -0700
Message-ID: <5612F84E.1030709@gmail.com>
References: <1444083297-3454-1-git-send-email-pch@ordbogen.com>
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
Received: from mail-io0-f181.google.com ([209.85.223.181]:36505 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbJEWXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 18:23:13 -0400
Received: by ioii196 with SMTP id i196so201926361ioi.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 15:23:13 -0700 (PDT)
In-Reply-To: <1444083297-3454-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2015 03:14 PM, Peter N=C3=B8rlund wrote:
> commit 0e884c78ee19e902f300ed147083c28a0c6302f0 ("ipv4: L3 hash-based
> multipath") broke compilation for i386 and arm due to dependency on
> 64-bit division.
>
> The problem is simply solved by using the proper macro for 64-bit
> divison.
>
> Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
> ---
>   net/ipv4/fib_semantics.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 0c49d2f..52254e8 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -569,8 +569,8 @@ static void fib_rebalance(struct fib_info *fi)
>   			upper_bound =3D -1;
>   		} else {
>   			w +=3D nexthop_nh->nh_weight;
> -			upper_bound =3D DIV_ROUND_CLOSEST(2147483648LL * w,
> -							total) - 1;
> +			upper_bound =3D DIV_ROUND_CLOSEST_ULL(2147483648ULL * w,
> +							    total) - 1;
>   		}
>  =20
>   		atomic_set(&nexthop_nh->nh_upper_bound, upper_bound);

Normally the correct comment would include something like the following=
=20
just before the signed-off-by line.
     Fixes: 0e884c78ee19 ("ipv4: L3 hash-based multipath")

I'm also kind of curious.  Why use 2147483648LL instead of just casting=
=20
w as a u64 and shifting by 31?  It seems like that would be more readab=
le.

Thanks.

- Alex
