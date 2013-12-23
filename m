From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv4: arp: update neighbour address when a gratuitous arp is received and arp_accept is set
Date: Mon, 23 Dec 2013 23:30:05 +0100
Message-ID: <20131223223005.GQ14073@order.stressinduktion.org>
References: <1387826492-25413-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48549 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627Ab3LWWaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 17:30:08 -0500
Content-Disposition: inline
In-Reply-To: <1387826492-25413-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 11:21:32AM -0800, Salam Noureddine wrote:
> @@ -910,7 +913,9 @@ static int arp_process(struct sk_buff *skb)
>  		   agents are active. Taking the first reply prevents
>  		   arp trashing and chooses the fastest router.
>  		 */
> -		override = time_after(jiffies, n->updated + n->parms->locktime);
> +		override = time_after(jiffies,
> +				      n->updated + n->parms->locktime) ||
> +			   is_garp;

Your patch is fine, but you need to rebase it again on net-next.
n->parms->locktime has been since updated to NEIGH_VAR(n->parms, LOCKTIME)
and thus this patch does not apply to net-next any more.

Greetings,

  Hannes
