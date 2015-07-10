From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 2/3] of_mdio: add new DT property 'autoneg' for fixed-link
Date: Fri, 10 Jul 2015 23:08:54 +0300
Message-ID: <55A02656.7020508@list.ru>
References: <559FF511.5080102@list.ru> <559FF63E.8020209@list.ru>
 <55A010F9.7030808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A010F9.7030808@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10.07.2015 21:37, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 10/07/15 09:43, Stas Sergeev wrote:
>> Currently for fixed-link the MAC driver decides whether to use the
>> link status auto-negotiation or not.
>> Unfortunately the auto-negotiation may not work when expected by
>> the MAC driver. Sebastien Rannou explains:
>> << Yes, I confirm that my HW does not generate an in-band status. AF=
AIK, it's
>> a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY=
 (with
>> inband status) is connected to the switch through QSGMII, and in thi=
s context
>> we are on the media side of the PHY. >>
>> https://lkml.org/lkml/2015/7/10/206
>>
>> This patch introduces the new boolean property 'autoneg' that allows
>> the user to request the auto-negotiation explicitly.
> The implementation looks better, but the name might still be slightly
> controversial. I would go with "use-in-band-status" which is more
> strictly defined than "autoneg" which could mean anything and everyth=
ing.
>
> What do you think?
I actually think autoneg is a bit better.

- Autonegotiation is a widely used and known term:
https://en.wikipedia.org/wiki/Autonegotiation
And who knows what in-band status is?
And, more importantly, who knows what is it used for?
Who even knows it is used for autonegotiation?

- When we set autoneg for fixed-link, we basically just
say "no MDIO here, but please do autoneg by any other
means, if possible".

- in-band status is an implementation delail, and it is
specific to a particular protocols. If you request the
in-band status for some protocol that doesn't support
it, perhaps you should get -EINVAL, because such a
config makes no sense. With autonegotiation, the rules
are not that strict: it can be "unimplemented", which doesn't
necessary mean nonsense in the config.

- autonegotiation is a wider term, and may be implemented
by some other means than the in-band status (which is
probably impossible for a fixed-link though).

- In the terms that the driver uses, it is autonegotiation, eg
MVNETA_GMAC_AUTONEG_CONFIG. And when you go down
the implementation details, you see MVNETA_GMAC_INBAND_AN_ENABLE,
which is just one AN bit of many.

So I really would prefer to keep things as is.
But if you insist, I can rename, but there will still be no
-EINVAL checks for obviously wrong configs.
