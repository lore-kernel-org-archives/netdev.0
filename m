From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Tue, 14 Jun 2016 09:02:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606140856010.2467@ja.home.ssi.bg>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org> <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55128 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750993AbcFNGCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 02:02:23 -0400
In-Reply-To: <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 13 Jun 2016, Hannes Frederic Sowa wrote:

> -	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
> -			   protocol, flow_flags, dst, src, dport, sport);
> +	fl4->flowi4_oif = oif;
> +	fl4->flowi4_iif = LOOPBACK_IFINDEX;
> +	fl4->flowi4_mark = sk->sk_mark;
> +	fl4->flowi4_tos = tos;
> +	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
> +	fl4->flowi4_proto = protocol;
> +	fl4->flowi4_flags = flow_flags;
> +	fl4->flowi4_secid = 0;
> +	fl4->flowi4_tun_key.tun_id = 0;
> +	fl4->daddr = dst;
> +	fl4->saddr = src;
> +	fl4->fl4_dport = dport;
> +	fl4->fl4_sport = sport;

	The way you initialize the fields adds new risks
when new field is added, it is difficult to track all such
places. If they are missed, the lookup will use random
value for the new field. I'm not sure what will compile,
may be something likes this?:

	*fl4 = (struct flowi4) {
		.flowi4_oif = oif,
		...
	};

Regards
