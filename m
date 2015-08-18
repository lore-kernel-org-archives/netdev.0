From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next RFC] net: ipv4: Send IGMP messages from highest scoped
 address
Date: Tue, 18 Aug 2015 15:36:41 +0200
Message-ID: <20150818133641.GB4381@lunn.ch>
References: <1439827764-29129-1-git-send-email-andrew@lunn.ch>
 <20150817.213158.1038537149649115817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32999 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbbHRNn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 09:43:57 -0400
Content-Disposition: inline
In-Reply-To: <20150817.213158.1038537149649115817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 09:31:58PM -0700, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Mon, 17 Aug 2015 18:09:24 +0200
> 
> > This is RFC because i personally don't know if this is the best fix.
> > The patch restores previous behavior, while still keeping the bug fix.
> > 
> > It is not obvious what is the correct source address for an IGMP
> > message when an interface has multiple addresses. IGMP messages are
> > sent either spontaneously, or as a result of a query. It could be
> > argued that when replying to a query, an address take from the same
> > subnet as the querier should be used. Doing this adds complexity for a
> > corner case which does not seem to effect people. In the spontaneous
> > case, there is no such hint, so an address has to be picked some other
> > way. Taking the highest scope address seems reasonable, and works for
> > me.
> 
> Yes, unfortunately almost no guidance is given in this area in the
> various RFCs.
> 
> Except that one recommended way to avoid forged IGMPs is to reject
> any IGMP that has a source address no on that interface's subnet.
> 
> And if people actually do that, then the link scope address is the
> best address to use and that is what we do now if I understand things
> correctly.

Hi David

We currently take the first address from the interface which is scope
link or higher.

Historically, the global scope address would of been used, but my
previous fix, which stopped it taking a global scope address from a
different interface altogether under some conditions, changed this
behaviour.

The first address from the interface, then broke one of my use
case. The querier is only in one of the subnets on this interface, and
using an address from the global scope address range. It then drops
the membership reports when they are sent from the first address on
the interface. This is why i want to restore the previous behaviour,
take the global scope address from this interface.

The patch works for me and is restoring previous behaviour, but is
that sufficient to make it correct?

     Andrew
