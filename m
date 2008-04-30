From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Wed, 30 Apr 2008 09:12:35 +0200
Message-ID: <48181BE3.6040407@trash.net>
References: <20080427142216.GB7480@ami.dom.local> <4814C618.3050506@trash.net> <20080427203630.GA9648@ami.dom.local> <4815D8D9.5020201@trash.net> <20080428145837.GB2870@ami.dom.local> <20080429205341.GA4356@ami.dom.local> <20080430070414.GA6828@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42299 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163AbYD3HMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 03:12:34 -0400
In-Reply-To: <20080430070414.GA6828@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Apr 29, 2008 at 10:53:41PM +0200, Jarek Poplawski wrote:
> ...
>> So it's really by design! (I don't know why I missed this, and why
> 
> ...Hmm..., actually this is the place:
> 
> sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> {
> ...
> 	x = q->ht[hash];
> 	if (x == SFQ_DEPTH) {
> 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
> ...
> 
> sfq counts on free slot always available here.


IIRC thats why the limit is capped at SFQ_DEPTH - 1.

