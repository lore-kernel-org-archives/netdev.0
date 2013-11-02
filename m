From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: pkt_sched: PIE AQM scheme
Date: Fri, 01 Nov 2013 17:56:38 -0700
Message-ID: <1383353798.4291.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383338722-6000-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:59681 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab3KBA4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 20:56:41 -0400
Received: by mail-pb0-f51.google.com with SMTP id xa12so1873909pbc.38
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 17:56:40 -0700 (PDT)
In-Reply-To: <1383338722-6000-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-01 at 13:45 -0700, Vijay Subramanian wrote:

> +
> +	if (!drop_early(sch, skb->len)) {
> +		/* we can enqueue the packet */
> +		q->stats.packets_in++;
> +
> +		if (qdisc_qlen(sch) > q->stats.maxq)
> +			q->stats.maxq = qdisc_qlen(sch);
> +
> +		return qdisc_enqueue_tail(skb, sch);

I am not sure why you mix skb->len and qdisc_len(skb)

Also, a default 200 packets limit sounds strange, was it actually tested
on a 10Gb link ?

Other than that, patch seems fine, thanks !
