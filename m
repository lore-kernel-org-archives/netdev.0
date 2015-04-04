From: Alexei Potashnik <alexei@purestorage.com>
Subject: RE: neigh use-after-free
Date: Fri, 3 Apr 2015 18:32:18 -0700
Message-ID: <61ca9aa7a9c9b1fa0e8973b2826e0115@mail.gmail.com>
References: <20150403202753.GF32724@Sligo.logfs.org>	 <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
	 <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5f0a512c725fbaf8f38dbc1bdd9d1b47@mail.gmail.com>	 <1428108249.25985.197.camel@edumazet-glaptop2.roam.corp.google.com>
	 <520964f8c9b65ad9a49545a30ecf6065@mail.gmail.com>	 <1428109844.25985.202.camel@edumazet-glaptop2.roam.corp.google.com>
 <1428110406.25985.203.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:46068 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751897AbbDDBcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 21:32:22 -0400
Received: by widdi4 with SMTP id di4so120636863wid.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 18:32:20 -0700 (PDT)
In-Reply-To: <1428110406.25985.203.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. Will try.

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>
>
> Please try following patch :
>
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c index
> 3de6542560288b3896ab243879a7b4a9b098ca0d..3a2928332b31bfd421ca409ba
> 9bc4e82f82b3552 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -957,7 +957,8 @@ int __neigh_event_send(struct neighbour *neigh,
> struct sk_buff *skb)
>  	rc = 0;
>  	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY |
> NUD_PROBE))
>  		goto out_unlock_bh;
> -
> +	if (neigh->dead)
> +		goto out_unlock_bh;
>  	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
>  		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
>  		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
>
