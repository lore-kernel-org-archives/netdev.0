From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 08:44:52 -0700
Message-ID: <CAGVrzcazh_URQw7nK3=aq-xg7sn48XVbaDdYtzzTEBB2bJUadQ@mail.gmail.com>
References: <55155AFC.4050800@list.ru> <20150327133907.GA11975@lunn.ch>
 <551560B9.1030505@list.ru> <20150327135904.GB11975@lunn.ch> <55156730.5030807@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34245 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363AbbC0Ppd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 11:45:33 -0400
In-Reply-To: <55156730.5030807@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-27 7:20 GMT-07:00 Stas Sergeev <stsp@list.ru>:
> 27.03.2015 16:59, Andrew Lunn =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> But there is no MDIO, because SGMII AFAIK doesn't need MDIO.
>>> SGMII has in-band status, but for some reason it seems currently
>>> linux is not ready for such setup - this is what my patch addresses=
=2E
>>
>> Hacking the fixed-link driver feels wrong to me. You probably want t=
o
>> implement an SGMII-link driver. With some refactoring you can probab=
ly
>> re-use some of the fixed-link driver code, but it should be a separa=
te
>> driver, with its own DT binding.
> Well I took the path of "the least resistance" of course...
> and the one that doesn't look unreasonable to me, but the separate
> driver is an option too. Though it will really be just the "same
> fixed-link with 3 added functions to change properties". Do we really
> need 2 mostly similar drivers? Esp when one includes the functionalit=
y
> of the other, and just adds a bit on top? Maybe having just one, with
> all the capabilities added?
> For example, maybe someone will later want the ability to alter the
> properties of fixed-link with ethtool or alike? Will this also requir=
e
> "just another fixed link driver"?
> Having one fully-featured driver will allow us to add the "sgmii-link=
"
> DT binding as an alias to "fixed-link" and some function like
> of_phy_fixed_link_is_sgmii() that will tell us whether we need an
> in-band status or not.
>
>> But i'm no export here. So lets see what others say.
> Right. If people will be negative to an addition to fixed-link driver=
,
> I'll take a look into adding a new DT binding - something I'd really
> like to avoid doing. :) More work, more code, and yet even a new conf=
ig
> option - this have to be justified.

See my other reply, I think that by register a fixed_link_update
callback and adjusting fixed_phy_status based on the SGMII in-band
decoded data you would get all you want to work without major surgery
to the current code. If we are missing information in fixed_phy_status
to support SGMII-specific properties, maybe we could add those.
--=20
=46lorian
