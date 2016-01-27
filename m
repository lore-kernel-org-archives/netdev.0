From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Tue, 26 Jan 2016 17:25:15 -0800
Message-ID: <56A81C7B.8050201@gmail.com>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch> <1453853499-11248-3-git-send-email-andrew@lunn.ch> <56A81047.4010802@gmail.com> <20160127010638.GA4815@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, aaro.koskinen@nokia.com,
	olof@lixom.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33429 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbcA0B0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 20:26:08 -0500
Received: by mail-pf0-f174.google.com with SMTP id x125so2810749pfb.0
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 17:26:07 -0800 (PST)
In-Reply-To: <20160127010638.GA4815@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/16 17:06, Andrew Lunn wrote:
> On Tue, Jan 26, 2016 at 04:33:11PM -0800, Florian Fainelli wrote:
>> On 26/01/16 16:11, Andrew Lunn wrote:
>>> PHY devices may only list clause 22, 45, and their PHY identifier
>>> values as compatible values. No other compatible strings are allowed.
>>> Make this clear in the documentation, and remove examples where
>>> make/model compatible strings are listed.
>>
>> Humm, should not we rather require Ethernet PHY Device Tree nodes to
>> have *at least* a "ethernet-phy-ieee802.3-c22" or
>> "ethernet-phy-ieee802.3-c45", and any other compatible string which
>> further specifies the hardware is also welcome?
> 
> At the moment, "ethernet-phy-ieee802.3-c45" is used, we look for it
> and act upon it. "ethernet-phy-ieee802.3-c22" is not used anywhere,
> other than my new of_mdiobus_child_is_phy(). Also, for backwards
> compatibility with older blobs, we can never assume one or the other
> will be present.
> 
> So you are suggesting we change around 200 ethphy nodes to add in
> "ethernet-phy-ieee802.3-c22", yet we don't actually do anything with
> it?

Well, we do now, since that is one of the results used by
of_mdiobus_child_is_phy(), but you are right, this does not scale.

What I would prefer seeing though is not removing nodes that have at
least two compatible strings, including one that is
"ethernet-phy-ieee802.3-c22", but those which have only one, like the
marvell ones that you patch, should have either an additional
"ethernet-phy-ieee802.3-c22", or none.

Does that make sense?
-- 
Florian
