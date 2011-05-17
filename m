From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 15:42:48 -0700
Message-ID: <1305672168.8149.966.camel@tardy>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <20110517.174431.1004332995189918916.davem@davemloft.net>
	 <m262p9yp5f.fsf@firstfloor.org>
	 <20110517.175044.2057517197524794568.davem@davemloft.net>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:1609 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399Ab1EQWmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:42:50 -0400
In-Reply-To: <20110517.175044.2057517197524794568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 17:50 -0400, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 17 May 2011 14:48:28 -0700
> 
> > David Miller <davem@davemloft.net> writes:
> > 
> >> Guys we can't time out fragments if we are not the final
> >> destination.
> > 
> > If you're not the final destination you should never even
> > try to reassemble them?
> > 
> > I'm probably missing something...
> 
> We're discussing the idea to do the defragmentation first
> so we can choose the flow properly and steer the packet
> to the correct cpu.
> 
> This also would allos each fragmented packet to traverse the
> stack only once (one route lookup etc.) instead of once per
> fragment.
> 
> Please read the rest of this thread, we have discussed this
> and now I'm repeating information solely for your benefit.

Well, I should probably be beaten with that stick too because I wasn't
thinking about forwarding, only being the destination system when I
broached the suggestion of doing RFS after reassembly.  I can see where
one *might* be able to do limited RPS when forwarding, but I didn't know
that RFS had been extended to forwarding.

Now though I see why you were rightfully concerned about timeouts -
given all the concerns about added latency from bufferbloat, I wouldn't
think that an additional 10 or perhaps even 1ms timeout on a reassembly
attempt to get the layer four header when forwarding would sit well with
folks - they will expect the fragments to flow through without
additional delay.

rick jones


