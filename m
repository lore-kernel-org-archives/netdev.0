From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Mon, 23 Jul 2007 22:14:49 +0100
Message-ID: <20070723221449.1b500447@oldman>
References: <20070720.223129.59470764.davem@davemloft.net>
	<p73lkd9vqfr.fsf@bingen.suse.de>
	<20070723105822.3a9fa152@oldman.hamilton.local>
	<20070723170642.GA13771@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52181 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbXGWVPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 17:15:17 -0400
In-Reply-To: <20070723170642.GA13771@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jul 2007 19:06:42 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> On Mon, Jul 23, 2007 at 10:58:22AM +0100, Stephen Hemminger wrote:
> > On 21 Jul 2007 15:26:00 +0200
> > Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > David Miller <davem@davemloft.net> writes:
> > > > 
> > > > Good candidates for taking advantage of multi-napi are:
> > > > 
> > > > 1) e1000
> > > > 2) ucc_geth
> > > > 3) ehea
> > > > 4) sunvnet
> > > 
> > > s2io.c
> > 
> > sky2.c could use it because of issues with dual-port that share
> > one napi for status.
> 
> Sorry, I didn't parse the sentence. Did you mean "couldn't use it" ...? 
> Also can you elaborate why it shouldn't work?

Sky2 would make a good case for decoupling because it can have:

	device0     device1
	    \            /
             napi poll

Right now both device's share the NAPI instance on device 0,
but it take some work to make sure that the core code doesn't
upset device1 when device0 is down.

Actually, dual port boards are rare, I have one but it is a PCI-E x4
board so a pain to find a system with a slot.
