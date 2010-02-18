From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 22:01:04 -0500
Message-ID: <1266462064.5719.78.camel@obelisk.thedillows.org>
References: <1266458370.5719.43.camel@obelisk.thedillows.org>
	 <1266459504.8446.201.camel@Joe-Laptop.home>
	 <1266460221.5719.60.camel@obelisk.thedillows.org>
	 <20100217.184100.232538560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100217.184100.232538560.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-02-17 at 18:41 -0800, David Miller wrote:
> From: David Dillow <dave@thedillows.org>
> Date: Wed, 17 Feb 2010 21:30:21 -0500
> 
> > No, because the routines that use tp->name are called both before and
> > after the netdev is registered. Prior to that time, it contains the PCI
> > slot name -- "00:01.0" etc -- so that the user can determine which card
> > is acting up. Once the card is registered, it has "ethX" to use a
> > commonly expected name for the card.
> 
> In my opinion that's awful.

Neither you nor Jeff seemed to think it was an issue 7+ years ago, and
Jeff liked it when it was suggested as a solution to another driver's
problems. But times change, sure. And people learn from experience.

I liked it because it consistent with eth device naming when it could
be, and gave them useful info to go on when it failed during
initialization. This well before dev_*(). I don't think it is
particularly broken today -- even if we added the PCI info, I'd still
want to know if it was eth0 or eth8 that died on me without having to go
track down which one belonged to the slot.

In any event, that's not going to be cleaned up tonight.

I'm perfectly fine with the netdev_<level> changes, and can grudgingly
live with the overlong format strings, but the pr_<level> changes make
the output worse, and don't help readability or maintainability in my
opinion. I'm don't see how dropping the typhoon patch slows Joe down, so
I'd like to avoid having to fix things up after the fact.
