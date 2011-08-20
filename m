From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net: rps: support 802.1Q
Date: Sat, 20 Aug 2011 02:12:49 +0100
Message-ID: <1313802769.2814.33.camel@deadeye>
References: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com>
	 <1313754853.2814.8.camel@deadeye>
	 <CABa6K_FhG9_XrCfhJDhhUArFEeG5FqOoU_HN1vY-TOKmjMxBKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51895 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab1HTBMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 21:12:53 -0400
In-Reply-To: <CABa6K_FhG9_XrCfhJDhhUArFEeG5FqOoU_HN1vY-TOKmjMxBKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-19 at 23:05 +0800, Changli Gao wrote:
> On Fri, Aug 19, 2011 at 7:54 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > Should this really be reading an unlimited number of tags?
> 
> Not unlimited, but it won't stop until reaching the end of the packet.

Right, I understand that the parsing is properly range-checked against
the length of the packet.

> >  What if an
> > attacker starts sending packets full of VLAN tags?  Since this runs
> > before netfilter, there would be no way to prevent those packets burning
> > our CPU time.  And if there are legitimately multiple VLAN tags, they
> > presumably won't all have the 802.1q Ethertype.
> >
> 
> Do we need to limit the number of rounds to stop this kind of "bad"
> packets from burning our CPU time?

Well, maybe.  Then again, the most effective way for an attacker to
waste a target's CPU time (aside from application-level vulnerabilities)
will often be just to send minimum size packets.

> Then,  __netif_receive_skb() has to
> be update too, so the inspection of tunnel in __skb_get_rxhash() does.

Yes, if we agree this is something worth defending against then we would
need to be consistent in limiting any such parsing loop in pre-netfilter
processing.

> Is there a such limitation in xfrm?

It appears to be limited to 6 levels of encapsulation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

