From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: Add default_advmss() methods to blackhole dst_ops
Date: Fri, 18 Feb 2011 21:16:42 +0800
Message-ID: <AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com>
References: <20110218050321.10415.qmail@science.horizon.com>
 <1298010735.2642.9.camel@edumazet-laptop> <1298023023.2595.170.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46018 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab1BRNRD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 08:17:03 -0500
In-Reply-To: <1298023023.2595.170.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 18, 2011 at 5:57 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
>
> I suspect following patch is needed
>
> CC Roland Dreier <roland@purestorage.com> because he fixed the
> default_mtu problem in commit ec831ea72ee5d7d47
> (net: Add default_mtu() methods to blackhole dst_ops)
>
> Thanks !
>
> [PATCH] net: Add default_advmss() methods to blackhole dst_ops
>
> Commit 0dbaee3b37e118a (net: Abstract default ADVMSS behind an
> accessor.) introduced a possible crash in tcp_connect_init(), when
> dst->default_advmss() is called from dst_metric_advmss()
>
> Reported-by: George Spelvin <linux@horizon.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Roland Dreier <roland@purestorage.com>
> ---
> =A0net/ipv4/route.c | =A0 =A07 +++++++
> =A0net/ipv6/route.c | =A0 =A06 ++++++
> =A02 files changed, 13 insertions(+)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 788a3e7..5edb605 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2712,6 +2712,12 @@ static unsigned int ipv4_blackhole_default_mtu=
(const struct dst_entry *dst)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static unsigned int ipv4_blackhole_default_advmss(const struct dst_e=
ntry *dst)
> +{
> + =A0 =A0 =A0 return 256;
> +}
> +
> +

I am wondering why magic number 256 is used here. Is there a special
reason? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
