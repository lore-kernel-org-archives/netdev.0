From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 14:48:18 -0800 (PST)
Message-ID: <20070302.144818.99455241.davem@davemloft.net>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net>
	<20070302.132638.38710461.davem@davemloft.net>
	<20070302140929.262e8460@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56369
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992692AbXCBWsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 17:48:20 -0500
In-Reply-To: <20070302140929.262e8460@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 2 Mar 2007 14:09:29 -0800

> On Fri, 02 Mar 2007 13:26:38 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Wed, 28 Feb 2007 17:18:46 -0800
> > 
> > > I was measuring bridging/routing performance and noticed this.
> > > 
> > > The current code runs the "all packet" type handlers before calling the
> > > bridge hook.  If an application (like some DHCP clients) is using AF_PACKET,
> > > this means that each received packet gets run through the Berkeley Packet Filter
> > > code in sk_run_filter (slow).
> > 
> > I know we closed this out by saying that even though performance
> > sucks, we can't really apply this without breaking things.
> 
> wrong.

I disagee, and your patch is still broken because as Jamal
pointed out (which you didn't address in any way) this breaks
traffic classification of bridged traffic as well.

If someone wants their network tap to hear all traffic, they do mean
all traffic, and this includes potentially seeing it multiple times
when things like bridging and virtual devices decap incoming frames.

We can't apply this.

Back to a workable solution, why doesn't DHCP specify a specific
device?  It would fix this performance problem completely, at the
application level.
