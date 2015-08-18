From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next RFC] net: ipv4: Send IGMP messages from highest scoped
 address
Date: Tue, 18 Aug 2015 22:31:44 +0200
Message-ID: <20150818203144.GL4381@lunn.ch>
References: <1439827764-29129-1-git-send-email-andrew@lunn.ch>
 <20150817.213158.1038537149649115817.davem@davemloft.net>
 <20150818133641.GB4381@lunn.ch>
 <20150818.120110.838819870003861953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33206 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbbHRUjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:39:01 -0400
Content-Disposition: inline
In-Reply-To: <20150818.120110.838819870003861953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 12:01:10PM -0700, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Tue, 18 Aug 2015 15:36:41 +0200
> 
> > We currently take the first address from the interface which is scope
> > link or higher.
> > 
> > Historically, the global scope address would of been used, but my
> > previous fix, which stopped it taking a global scope address from a
> > different interface altogether under some conditions, changed this
> > behaviour.
> > 
> > The first address from the interface, then broke one of my use
> > case. The querier is only in one of the subnets on this interface, and
> > using an address from the global scope address range. It then drops
> > the membership reports when they are sent from the first address on
> > the interface. This is why i want to restore the previous behaviour,
> > take the global scope address from this interface.
> > 
> > The patch works for me and is restoring previous behaviour, but is
> > that sufficient to make it correct?
> 
> Preferring link-scope addresses make so much more sense for me.
> 
> The querier is on the local network, and he can do things like the
> validity check on the subnet of the source address to try and avoid
> forged IGMP responses.
> 
> So if anything I'd be advising you to change the code to prefer
> link local addresses on the interface and keep avoiding global
> addresses, as it is the only correct source address selection
> scheme I can think of for IGMPs.

Hi David

O.K, thanks for the discussion, and this patch can be ignored.

     Andrew
