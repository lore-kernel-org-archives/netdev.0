From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next] pkt_sched: sch_htb: Warn on too many events.
Date: Wed, 28 Jan 2009 17:18:12 +0100
Message-ID: <49808544.5010304@trash.net>
References: <20090128125230.GA6282@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34737 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbZA1QSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 11:18:14 -0500
In-Reply-To: <20090128125230.GA6282@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> pkt_sched: sch_htb: Warn on too many events.
> 
> Let's get some info on possible config problems. This patch brings
> back an old warning, but it's printed only once now. BTW a "class
> isn't work conserving" warning is also limited to once per qdisc
> instead of per class.
> 
> With feedback from Patrick McHardy <kaber@trash.net>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
> 
>  		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
>  		if (likely(skb != NULL))
>  			break;
> -		if (!cl->warned) {
> +		if (!(q->warned & HTB_WARN_NONCONSERVING)) {
>  			printk(KERN_WARNING
>  			       "htb: class %X isn't work conserving ?!\n",
>  			       cl->common.classid);
> -			cl->warned = 1;
> +			q->warned |= HTB_WARN_NONCONSERVING;

How about making this flag and the warning message (in a out-of-line
function) globally available? Other qdiscs (f.i. HFSC) can't deal with
inner non-work-conserving qdiscs as well.
