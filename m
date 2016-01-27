From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 08:31:21 -0800
Message-ID: <1D1D50D7-5C95-4FD6-9919-6898DE05B5DA@gmail.com>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch> <1453853499-11248-3-git-send-email-andrew@lunn.ch> <56A81047.4010802@gmail.com> <20160127010638.GA4815@lunn.ch> <56A81C7B.8050201@gmail.com> <20160127015755.GB4815@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, aaro.koskinen@nokia.com,
	olof@lixom.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36776 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158AbcA0Qba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 11:31:30 -0500
Received: by mail-oi0-f68.google.com with SMTP id y78so595424oif.3
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 08:31:30 -0800 (PST)
In-Reply-To: <20160127015755.GB4815@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On January 26, 2016 5:57:55 PM PST, Andrew Lunn <andrew@lunn.ch> wrote:
>> Well, we do now, since that is one of the results used by
>> of_mdiobus_child_is_phy(),
>
>It uses it, but do not rely on it, since for backwards compatibility,
>we cannot assume it is there.
>
>You can never change an optional parameter to a mandatory parameter in
>DT. To do so breaks backwards compatibility.
>
>> What I would prefer seeing though is not removing nodes that have at
>> least two compatible strings, including one that is
>> "ethernet-phy-ieee802.3-c22", but those which have only one, like the
>> marvell ones that you patch, should have either an additional
>> "ethernet-phy-ieee802.3-c22", or none.
>
>So you are saying, if there is an "ethernet-phy-ieee802.3-c22" or an
>"ethernet-phy-ieee802.3-45" you can also have any other random junk,
>which we are going to ignore, since we have no way to verify, hence we
>have to assume it is broken, yet we need to be backwards compatible
>with it.
>
>Did you notice:
>
>+       { .compatible = "marvell,88e1310", },
>+       { .compatible = "marvell,88E1510", },
>
>No consistency with the 'e'. We would just be encouraging people to
>add more inconsistent stuff.

You are right, I am convinced now. If somebody needs to know the exact PHY ID a priori, then you are also likely to use the more descriptive compatible string including that ID.

So:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

-- 
Florian
