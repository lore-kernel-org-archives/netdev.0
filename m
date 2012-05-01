From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Tue, 01 May 2012 06:09:17 -0700
Message-ID: <1335877757.26217.67.camel@joe2Laptop>
References: <1335838029.11396.12.camel@edumazet-glaptop>
	 <1335842663.26217.10.camel@joe2Laptop>
	 <1335854091.11396.21.camel@edumazet-glaptop>
	 <1335873153.26217.35.camel@joe2Laptop>
	 <1335875351.11396.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44010 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754781Ab2EANJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 09:09:20 -0400
In-Reply-To: <1335875351.11396.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 14:29 +0200, Eric Dumazet wrote:
> On Tue, 2012-05-01 at 04:52 -0700, Joe Perches wrote:
> 
> > That's true for cpus with sufficient cache but prefetch
> > might be wasteful for cpus without (like some ARMs).
> > 
> > Some of the sk_backlog_rcv functions like tcp_v4_do_rcv
> > can be relatively large.
> 
> You speak of icache here. Thats different matter.
> 
> My patch does a prefetch of data (dcache)

Actually I meant cpus with an integrated cache
like the old arm 710 and the sh3/7710.

I think those are still possible compilation
targets, but perhaps no one cares anymore.

> How this prefetch() is different than other ones in kernel ?

I'm not suggesting prefetch isn't useful.

If prefetch improves performance for the general case
it's good.  If the prefetch can also be trivially
compile time wrapped to not impact older supported
targets, I think that's good too.

> For old cpus, you can use linux 2.4 it works much better.

Deprecating older targets may not be a bad thing either.

cheers, Joe
