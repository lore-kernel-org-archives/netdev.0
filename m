From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Mon, 28 Dec 2015 15:02:13 -0500 (EST)
Message-ID: <20151228.150213.1896994611172806482.davem@davemloft.net>
References: <20151228.004427.1444978630699405304.davem@davemloft.net>
	<20151228085825.GA30297@lunn.ch>
	<ACCDAA4E-5186-4920-BC1E-4A5D4D55F4EE@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469AbbL1UCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 15:02:17 -0500
In-Reply-To: <ACCDAA4E-5186-4920-BC1E-4A5D4D55F4EE@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 28 Dec 2015 09:27:25 -0800

> On December 28, 2015 12:58:25 AM PST, Andrew Lunn <andrew@lunn.ch> wrote:
>>On Mon, Dec 28, 2015 at 12:44:27AM -0500, David Miller wrote:
>>> From: David Miller <davem@davemloft.net>
>>> Date: Mon, 28 Dec 2015 00:32:43 -0500 (EST)
>>> 
>>> > From: Andrew Lunn <andrew@lunn.ch>
>>> > Date: Sun, 27 Dec 2015 12:58:25 +0100
>>> > 
>>> >> This patchset add ethtool support for reading statistics from the
>>PHY.
>>> >> The Marvell and Micrel Phys are then extended to report receiver
>>> >> packet errors and idle errors.
>>> >> 
>>> >> v2:
>>> >>   Fix linking when phylib is not enabled.
>>> > 
>>> > Series applied, thanks Andrew.
>>> 
>>> I have to revert this.
>>> 
>>> You can't call into PHY library code from net/core/ethtool.c,
>>> because PHY lib can be modular.
>>
>>O.K.
>>
>>How about we change PHYLIB from a tristate to a bool?
> 
> Could we make this in a two layer design instead? Core ethtool changes call into getter functions which are implemented by the netdev driver, if the netdev driver happens to use PHYLIB, calls into the PHYLIB helpers with its phydev? That would also allow a network driver already supporting PHY stats to report them through your new interface.

Or just put the helpers in net/core/ethtool.c
