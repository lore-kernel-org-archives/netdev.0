From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC][PATCHv2 2.6.18-rc4-mm3 3/3] net/ipv4:  misc. support files
Date: Mon, 28 Aug 2006 20:28:46 +0200
Message-ID: <44F335DE.5030307@trash.net>
References: <200608231150.37895@strip-the-willow> <39e6f6c70608280548p5ba363d7o18cfd3bdb2f9e894@mail.gmail.com> <200608281513.49959@strip-the-willow> <200608281910.50647@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jmorris@namei.org, alan@lxorguk.ukuu.org.uk,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, kaber@coreworks.de,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:20945 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750930AbWH1S2v
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 14:28:51 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200608281910.50647@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gerrit@erg.abdn.ac.uk wrote:
> [Net/IPv4]: REVISED Miscellaneous changes which complete the 
>             v4 support for UDP-Lite.
> 

> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -467,6 +467,7 @@ u16 xfrm_flowi_sport(struct flowi *fl)
>  	switch(fl->proto) {
>  	case IPPROTO_TCP:
>  	case IPPROTO_UDP:
> +	case IPPROTO_UDPLITE:
>  	case IPPROTO_SCTP:
>  		port = fl->fl_ip_sport;
>  		break;
> @@ -492,6 +493,7 @@ u16 xfrm_flowi_dport(struct flowi *fl)
>  	switch(fl->proto) {
>  	case IPPROTO_TCP:
>  	case IPPROTO_UDP:
> +	case IPPROTO_UDPLITE:
>  	case IPPROTO_SCTP:
>  		port = fl->fl_ip_dport;
>  		break;

You also need to adapt _decode_session[46] in xfrm[46]_policy.c for
IPsec. While you're at it you might consider adjusting xt_tcpudp,
xt_multiport, ipt_LOG and ip6t_LOG as well to get some basic
netfilter support. I'm going to take care of connection tracking
and NAT once this is in mainline.

