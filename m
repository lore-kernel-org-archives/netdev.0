From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Sun, 12 Jan 2014 08:42:45 +0100
Message-ID: <20140112074245.GF6586@order.stressinduktion.org>
References: <20140109201411.317040@gmx.com> <20140110063638.GA17866@order.stressinduktion.org> <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com> <20140110071049.GB17866@order.stressinduktion.org> <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com> <20140110074325.GC17866@order.stressinduktion.org> <20140110075005.GD17866@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57704 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaALHmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 02:42:46 -0500
Content-Disposition: inline
In-Reply-To: <20140110075005.GD17866@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 08:50:05AM +0100, Hannes Frederic Sowa wrote:
> > > Its a bit late here, so maybe following is just stupid :
> > > Cant we do the fib_rule_put() inside ipmr_fib_lookup() ?
> > 
> > We could add bool noref to ipmr_fib_lookup indicating we want to drop
> > reference to rule just after lookup.
> > 
> > I'll check if freeing a rule has additional side-effects on dependencies
> > in reg_vif_xmit. That would be a nice solution actually, thanks!
> 
> Hmm, rule holds a reference to the net namespace in use. I don't know
> if we want to add this special case. I guess net-namespace reference
> cannot be removed while processing ndo_start_xmit callback but I don't
> like this special case somehow. But I guess it is possible.
> 
> Your opinion on that?

Hm, Eric. If we do that we can just specifiy FIB_LOOKUP_NOREF
unconditionally. FIB_LOOKUP_NOREF has no other side effects on a ipmr
lookup as taking the reference on the rule, which we would drop after
that.

So we would actually be going back to the first patch in this thread. I
guess it is just a matter of style?

Greetings,

  Hannes
