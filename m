From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support
 for DSA ageing time
Date: Mon, 18 Jul 2016 22:13:34 +0200
Message-ID: <20160718201334.GS31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com>
 <20160718191644.GG31103@lunn.ch>
 <87d1malpcd.fsf@ketchup.mtl.sfl>
 <20160718193253.GJ31103@lunn.ch>
 <87eg6q3efp.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45015 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbcGRUNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 16:13:37 -0400
Content-Disposition: inline
In-Reply-To: <87eg6q3efp.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 03:59:38PM -0400, Vivien Didelot wrote:
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> Nope, the bridge ageing time is not per-port, even though switchdev ops
> >> are per-port by design. This is a switch-wide attribute.
> >
> > So you are saying the core is doing all the reference counting, etc,
> > when swapping between fast and slow ageing?
> 
> I don't see how checking for the fastest ageing time would fix support
> for multiple bridges...

The bridge should switch to fast ageing after a topology change to
flush out entries which are now wrong. Using the short age time for
too long results in a bit more inefficiency, in that entries time out
faster than they need to. But if we go back to slow ageing too
quickly, e.g. because of another bridge, we get wrong operation, in
that bad entries can get stuck in the table for up to 5 minutes.

So either we need to keep fast ageing as long as there is one bridge
fast ageing, or we need to flush the whole MAC cache for a bridge on
topology change and don't bother with fast ageing at all.

> Maybe we can keep it simple for the moment with this switch-wide
> set_ageing_time operation, and later add a patch for the DSA layer to
> cache and elect the ageing time per-port or per-bridge.

I don't think it can be done at the DSA layer. It does not have the
information needed.

	    Andrew
