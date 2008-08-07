From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 7 Aug 2008 12:05:37 +0000
Message-ID: <20080807120536.GA13299@ff.dom.local>
References: <20080806224248.18266k9ahc5nkk8w@hayate.ip6> <20080806215258.GA3306@ami.dom.local> <20080806.202636.246995904.davem@davemloft.net> <20080806.220911.91192536.davem@davemloft.net> <20080807100910.GA12391@ff.dom.local> <20080807143654.16955ngk5tnp5kzk@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:64314 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268AbYHGMZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:25:11 -0400
Received: by ug-out-1314.google.com with SMTP id h2so327791ugf.16
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 05:25:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080807143654.16955ngk5tnp5kzk@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 02:36:54PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>
>> There is also some doubt about differences between ->enqueue() and
>> ->requeue() wrt. kfree_skb() and returning codes: maybe it would be
>> better (for uniformity) to add similar changes to requeues (and
>> dev_requeue_skb()) as well?
>>
>
> I think requeue should be changed to return same as enqueue, netem even
> uses requeue as enqueue replacement for packet reordering. Maybe add
> new function qdisc_requeue_tree to handle freeing and masking flags and
> change outside uses of requeue to use it (qdisc_peek_len in hfsc,
> sch_atm_dequeue, dev_requeue_skb).

Yes, good point again: if ->enqueue() could be mixed with ->requeue()
there is more than uniformity argument to do the change everywhere.

Jarek P.
