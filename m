From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Mon, 28 Dec 2015 12:28:25 -0800
Message-ID: <883CA286-6907-4663-9B96-95FC7670456E@gmail.com>
References: <20151228.004427.1444978630699405304.davem@davemloft.net> <20151228085825.GA30297@lunn.ch> <ACCDAA4E-5186-4920-BC1E-4A5D4D55F4EE@gmail.com> <20151228.150213.1896994611172806482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34200 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbbL1U2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 15:28:31 -0500
Received: by mail-ob0-f178.google.com with SMTP id wp13so13085695obc.1
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 12:28:30 -0800 (PST)
In-Reply-To: <20151228.150213.1896994611172806482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On December 28, 2015 12:02:13 PM PST, David Miller <davem@davemloft.net> wrote:
>From: Florian Fainelli <f.fainelli@gmail.com>
>Date: Mon, 28 Dec 2015 09:27:25 -0800
>
>> On December 28, 2015 12:58:25 AM PST, Andrew Lunn <andrew@lunn.ch>
>wrote:
>>>On Mon, Dec 28, 2015 at 12:44:27AM -0500, David Miller wrote:
>>>> From: David Miller <davem@davemloft.net>
>>>> Date: Mon, 28 Dec 2015 00:32:43 -0500 (EST)
>>>> 
>>>> > From: Andrew Lunn <andrew@lunn.ch>
>>>> > Date: Sun, 27 Dec 2015 12:58:25 +0100
>>>> > 
>>>> >> This patchset add ethtool support for reading statistics from
>the
>>>PHY.
>>>> >> The Marvell and Micrel Phys are then extended to report receiver
>>>> >> packet errors and idle errors.
>>>> >> 
>>>> >> v2:
>>>> >>   Fix linking when phylib is not enabled.
>>>> > 
>>>> > Series applied, thanks Andrew.
>>>> 
>>>> I have to revert this.
>>>> 
>>>> You can't call into PHY library code from net/core/ethtool.c,
>>>> because PHY lib can be modular.
>>>
>>>O.K.
>>>
>>>How about we change PHYLIB from a tristate to a bool?
>> 
>> Could we make this in a two layer design instead? Core ethtool
>changes call into getter functions which are implemented by the netdev
>driver, if the netdev driver happens to use PHYLIB, calls into the
>PHYLIB helpers with its phydev? That would also allow a network driver
>already supporting PHY stats to report them through your new interface.
>
>Or just put the helpers in net/core/ethtool.c

That would work, Intel drivers could benefit from that interface if it is not too phydev centric. We would have to know if the netdev uses phylib, but that's already the case for things like WoL and MII ioctl.


-- 
Florian
