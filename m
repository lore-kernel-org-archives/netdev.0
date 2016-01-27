From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 02:57:55 +0100
Message-ID: <20160127015755.GB4815@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
 <1453853499-11248-3-git-send-email-andrew@lunn.ch>
 <56A81047.4010802@gmail.com>
 <20160127010638.GA4815@lunn.ch>
 <56A81C7B.8050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, aaro.koskinen@nokia.com,
	olof@lixom.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43393 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbcA0B56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 20:57:58 -0500
Content-Disposition: inline
In-Reply-To: <56A81C7B.8050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, we do now, since that is one of the results used by
> of_mdiobus_child_is_phy(),

It uses it, but do not rely on it, since for backwards compatibility,
we cannot assume it is there.

You can never change an optional parameter to a mandatory parameter in
DT. To do so breaks backwards compatibility.

> What I would prefer seeing though is not removing nodes that have at
> least two compatible strings, including one that is
> "ethernet-phy-ieee802.3-c22", but those which have only one, like the
> marvell ones that you patch, should have either an additional
> "ethernet-phy-ieee802.3-c22", or none.

So you are saying, if there is an "ethernet-phy-ieee802.3-c22" or an
"ethernet-phy-ieee802.3-45" you can also have any other random junk,
which we are going to ignore, since we have no way to verify, hence we
have to assume it is broken, yet we need to be backwards compatible
with it.

Did you notice:

+       { .compatible = "marvell,88e1310", },
+       { .compatible = "marvell,88E1510", },

No consistency with the 'e'. We would just be encouraging people to
add more inconsistent stuff.

    Andrew
