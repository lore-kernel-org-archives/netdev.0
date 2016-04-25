From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next] net: dsa: Provide CPU port statistics to
 master netdev
Date: Mon, 25 Apr 2016 23:43:42 +0200
Message-ID: <20160425214342.GB5538@lunn.ch>
References: <1461175101-13506-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45795 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965237AbcDYVnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 17:43:46 -0400
Content-Disposition: inline
In-Reply-To: <1461175101-13506-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 10:58:21AM -0700, Florian Fainelli wrote:
> This patch overloads the DSA master netdev, aka CPU Ethernet MAC to also
> include switch-side statistics, which is useful for debugging purposes,
> when the switch is not properly connected to the Ethernet MAC (duplex
> mismatch, (RG)MII electrical issues etc.).
> 
> We accomplish this by retaining the original copy of the master netdev's
> ethtool_ops, and just overload the 3 operations we care about:
> get_sset_count, get_strings and get_ethtool_stats so as to intercept
> these calls and call into the original master_netdev ethtool_ops, plus
> our own.

Hi Florian

Interesting concept. My one concern is that by concatenating the two
sets of statistics, we get a name clash. I'm not sure the Marvell
switch statistics counters have different names to the Marvell
Ethernet driver statistics counters. ethtool does not care, but maybe
an SNMP agent using these statistics might not be too happy seeing the
same name twice?

     Andrew
