From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 07 Aug 2008 14:36:54 +0300
Message-ID: <20080807143654.16955ngk5tnp5kzk@hayate.ip6>
References: <20080806224248.18266k9ahc5nkk8w@hayate.ip6>
	<20080806215258.GA3306@ami.dom.local>
	<20080806.202636.246995904.davem@davemloft.net>
	<20080806.220911.91192536.davem@davemloft.net>
	<20080807100910.GA12391@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:52551 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757969AbYHGMcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:32:14 -0400
In-Reply-To: <20080807100910.GA12391@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

> There is also some doubt about differences between ->enqueue() and
> ->requeue() wrt. kfree_skb() and returning codes: maybe it would be
> better (for uniformity) to add similar changes to requeues (and
> dev_requeue_skb()) as well?
>

I think requeue should be changed to return same as enqueue, netem even
uses requeue as enqueue replacement for packet reordering. Maybe add
new function qdisc_requeue_tree to handle freeing and masking flags and
change outside uses of requeue to use it (qdisc_peek_len in hfsc,
sch_atm_dequeue, dev_requeue_skb).

  - Jussi

