From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: restore "overhead xxx" handling
Date: Mon, 03 Jun 2013 07:08:03 -0700
Message-ID: <1370268483.24311.145.camel@edumazet-glaptop>
References: <1370217305.24311.104.camel@edumazet-glaptop>
	 <20130603155621.0cb53b1b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Vimalkumar <j.vimal@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36863 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab3FCOIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 10:08:06 -0400
Received: by mail-pd0-f169.google.com with SMTP id y11so5763911pdj.28
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 07:08:04 -0700 (PDT)
In-Reply-To: <20130603155621.0cb53b1b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 15:56 +0200, Jesper Dangaard Brouer wrote:

> Would it make sense to add the "overhead" in qdisc_pkt_len_init() or
> qdisc_calculate_pkt_len(), thus updating qdisc_skb_cb(skb)->pkt_len
> instead?  (And perhaps also address the per GSO issue).

qdisc_pkt_len_init() is generic (OK for all qdisc)

Each HTB class can have its own computations : 
One for the rate, one for the ceil.
It has to be done in HTB.

If only the overhead is needed, its kind of easy for GSO packets, as we
already have gso_segs in hand.

pktlen = qdisc_skb_cb(skb)->pkt_len + gso_segs * overhead;

That will be a net-next patch, since it's not a regression.
