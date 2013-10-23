From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] net: initialize hashrnd in flow_dissector with net_get_random_once
Date: Wed, 23 Oct 2013 16:13:09 +0200
Message-ID: <20131023141309.GC26236@order.stressinduktion.org>
References: <20131023111219.GA31531@order.stressinduktion.org> <1382536714.7572.18.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52899 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab3JWONK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 10:13:10 -0400
Content-Disposition: inline
In-Reply-To: <1382536714.7572.18.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 06:58:34AM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-23 at 13:12 +0200, Hannes Frederic Sowa wrote:
> > We also can defer the initialization of hashrnd in flow_dissector
> > to its first use. Since net_get_random_once is irqsave now we don't
> > have to audit the call paths if one of this functions get called by an
> > interrupt handler.
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> This really works well if CONFIG_JUMP_LABEL=y
> 
> I am afraid some arches do not really have this.

This is the problem with all users of net_get_random_once.

If an architecture does not have JUMP_LABEL or gcc does not provide
CC_HAVE_ASM_GOTO we have an unlikely branch in the code path and branch
to the epilogue of the function to generate the hash for the first
time. After that it's "just" a likely atomic boolean test.

I guess it is not that important to have a good secret hash key here as
this is solely used to dispatch the packets to cpus and does not store
anything in tables.

Greetings,

  Hannes
