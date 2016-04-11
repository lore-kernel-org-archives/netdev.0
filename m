From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/7] dsa: Rename phys_port_mask to user_port_mask
Date: Mon, 11 Apr 2016 22:31:55 +0200
Message-ID: <20160411203155.GA32194@lunn.ch>
References: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
 <1460404209-32083-7-git-send-email-andrew@lunn.ch>
 <570C0328.5030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53486 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbcDKUcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 16:32:03 -0400
Content-Disposition: inline
In-Reply-To: <570C0328.5030108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2016 at 01:03:52PM -0700, Florian Fainelli wrote:
> On 11/04/16 12:50, Andrew Lunn wrote:
> > The phys in phys_port_mask suggests this mask is about PHYs. In fact,
> > it means physical ports. Rename to user_port_mask, indicating user
> > ports of the switch, which is hopefully less confusing.
> 
> Even though the change looks fine in principle, I am more worried about
> the difficulty for people to backport fixes because of the renaming
> happening here. How about "enabled_ports_mask" as a name?

I'm fine with that. Anything, so long as it does not contain phys.

> Did not
> Guenter had a helper function at some point which tested for (1 << port
> & ds->phys_port_mask)?

Maybe you are thinking of:

static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
{
        return ds->phys_port_mask & (1 << p) && ds->ports[p];
}
 
So how about initialized_port_mask, although it is a bit long.

   Andrew
