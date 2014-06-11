From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net_sched: drr: warn when qdisc is not work
 conserving
Date: Wed, 11 Jun 2014 15:59:22 -0700 (PDT)
Message-ID: <20140611.155922.90485024579028824.davem@davemloft.net>
References: <1402511718-24203-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347AbaFKW7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:59:23 -0400
In-Reply-To: <1402511718-24203-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 11 Jun 2014 20:35:18 +0200

> The DRR scheduler requires that items on the active list are work
> conserving, i.e. do not hold on to skbs for throttling purposes, etc.
> Attaching e.g. tbf renders DRR useless because all other classes on the
> active list are delayed as well.
> 
> So, warn users that this configuration won't work as expected; we
> already do this in couple of other qdiscs, see e.g.
> 
> commit b00355db3f88d96810a60011a30cfb2c3469409d
> ('pkt_sched: sch_hfsc: sch_htb: Add non-work-conserving warning handler')
> 
> The 'const' change is needed to avoid compiler warning ("discards 'const'
> qualifier from pointer target type").
> 
> tested with:
> drr_hier() {
>         parent=$1
>         classes=$2
>         for i in  $(seq 1 $classes); do
>                 classid=$parent$(printf %x $i)
>                 tc class add dev eth0 parent $parent classid $classid drr
> 		tc qdisc add dev eth0 parent $classid tbf rate 64kbit burst 256kbit limit 64kbit
>         done
> }
> tc qdisc add dev eth0 root handle 1: drr
> drr_hier 1: 32
> tc filter add dev eth0 protocol all pref 1 parent 1: handle 1 flow hash keys dst perturb 1 divisor 32
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
