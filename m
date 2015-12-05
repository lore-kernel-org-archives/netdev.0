From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] Set DF bit for IPv4 GRE tunnels with fixed TTL
Date: Sat, 5 Dec 2015 13:48:42 -0800
Message-ID: <CALnjE+rSw8b5m6Z3nWr2QaHBu-rMM2Ly7Q27=9v3w6nnodtxQQ@mail.gmail.com>
References: <56634F31.3000609@shemyak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Konstantin Shemyak <konstantin@shemyak.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33261 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbbLEVsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 16:48:43 -0500
Received: by iouu10 with SMTP id u10so151748378iou.0
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 13:48:42 -0800 (PST)
In-Reply-To: <56634F31.3000609@shemyak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 5, 2015 at 12:55 PM, Konstantin Shemyak
<konstantin@shemyak.com> wrote:
> The DF bit on IPv4 GRE tunnels with fixed TTL is enforced in order
> to prevent networking loops. This was the original behavior of GRE
> tunnels, lost in the refactoring.
>
> Signed-off-by: Konstantin Shemyak <konstantin@shemyak.com>
> ---
>  net/ipv4/ip_gre.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 6145214..485bf27 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -679,6 +679,10 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
>                     ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING)))
>                         return -EINVAL;
>         }
> +
> +        if (p.iph.ttl)
> +                p.iph.frag_off |= htons(IP_DF);
> +

Same code already exist in ip_tunnel_ioctl() which is common function
for IP based tunnel modules. Why does that not work?


>         p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
>         p.o_flags = gre_flags_to_tnl_flags(p.o_flags);
>
> --
> 1.9.1
>
