From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.7)
Date: Thu, 13 Jan 2011 21:37:49 +0100
Message-ID: <1294951069.3403.11.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61440 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756789Ab1AMUnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 15:43:14 -0500
Received: by wyb28 with SMTP id 28so2121693wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 12:42:32 -0800 (PST)
In-Reply-To: <20110113092706.154748c2@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 09:27 -0800, Stephen Hemminger a =C3=A9=
crit :
> +	/* Admit new packet */
> +	if (likely(choke_len(q) < q->limit)) {
> +
> +		q->tab[q->tail] =3D skb;
> +		q->tail =3D (q->tail + 1) & q->tab_mask;
> +
> +		sch->qstats.backlog +=3D qdisc_pkt_len(skb);
> +		qdisc_update_bstats(sch, skb);
> +		sch->q.qlen =3D choke_len(q) - q->holes;
> +		return NET_XMIT_SUCCESS;
> +	}
> +

You now must use qdisc_bstats_update() ;)



