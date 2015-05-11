From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Mon, 11 May 2015 11:09:49 -0400 (EDT)
Message-ID: <20150511.110949.1369224056076525434.davem@davemloft.net>
References: <cover.1431203900.git.daniel@iogearbox.net>
	<20150510170550.GA4442@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbbEKPJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:09:51 -0400
In-Reply-To: <20150510170550.GA4442@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 10 May 2015 19:05:50 +0200

> On Sat, May 09, 2015 at 10:51:30PM +0200, Daniel Borkmann wrote:
>> These are a couple of cleanups to make ingress a bit more lightweight.
> 
> This is plain wrong at many levels.
> 
> You're persisting on embedding the ingress code into the core, and you
> have to remember that most users don't need this. Modules allows
> people to get the code that they need into the core, with this
> approach, they have no other choice other than disable from .config
> this if they don't need it.
> 
> This has to be done the other way around. I just sent a patchset to
> clean up this that in exactly the other direction, as a result,
> performance is improved for users that don't need this.
> 
> We should do things to make users aware that when they request
> features, they have to pay a performance cost, and that happens by
> when you invoke:
> 
>         tc qdisc add dev eth0 handle ffff: ingress
> 
> David already stated before that ingress path is performance critical,
> but you insist on trying to get qdisc ingress faster *at any cost*.

Pablo I think you are overreacting here.

What Daniel and Alexei are doing here is quite reasonable.

There is no difference between having ingress qdisc hanging off of
netdevice vs. the classifier list.  They both serve the same purpose
and the change to use the classifier list merely removes one level
of indirection.

I also am confident that the cost for non-users is equivalent before
and after this patch series.  Or at least, it very much should be.

Therefore I am going to apply these patches, and I wish you would work
more closely with Daniel and Alexei because I am more than convinced
that you share the same exact goals.

Thanks.
