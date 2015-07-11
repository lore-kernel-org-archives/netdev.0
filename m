From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 2/3] of_mdio: add new DT property 'autoneg' for fixed-link
Date: Sat, 11 Jul 2015 12:15:24 +0300
Message-ID: <55A0DEAC.3020801@list.ru>
References: <559FF511.5080102@list.ru> <559FF63E.8020209@list.ru>
 <55A010F9.7030808@gmail.com> <55A02656.7020508@list.ru>
 <55A02D90.8090903@gmail.com> <55A032F5.8020801@list.ru>
 <55A061CC.8060504@gmail.com>
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
In-Reply-To: <55A061CC.8060504@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

11.07.2015 03:22, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 10/07/15 14:02, Stas Sergeev wrote:
>> 10.07.2015 23:39, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> - in-band status is an implementation delail, and it is
>>>> specific to a particular protocols. If you request the
>>>> in-band status for some protocol that doesn't support
>>>> it, perhaps you should get -EINVAL, because such a
>>>> config makes no sense. With autonegotiation, the rules
>>>> are not that strict: it can be "unimplemented", which doesn't
>>>> necessary mean nonsense in the config.
>>> So by specifying "autoneg", you are not specific about the kind of
>>> auto-negotiation protocol available, which is precisely my point: y=
ou
>>> need to go down to that level of detail for this to be useful. So m=
aybe
>>> something like:
>>>
>>> autoneg =3D "in-band-status" would actually be a better thing in te=
rms of
>>> description because then you would tell what can be made
>>> available/working?
>> I would agree with this if your argument below is true (see below).
>>
>>>> - autonegotiation is a wider term, and may be implemented
>>>> by some other means than the in-band status (which is
>>>> probably impossible for a fixed-link though).
>>>>
>>>> - In the terms that the driver uses, it is autonegotiation, eg
>>>> MVNETA_GMAC_AUTONEG_CONFIG. And when you go down
>>>> the implementation details, you see MVNETA_GMAC_INBAND_AN_ENABLE,
>>>> which is just one AN bit of many.
>>> But arguably, there could be another auto-negotiation method, which=
 is
>>> not in-band status related, which means that you would need a way t=
o
>>> distinguish between using in-band status, or using something else o=
r
>>> nothing, would not you?
>> "something else" is a big question here.
>> Can you think of _any_ other way that is both not an MDIO
>> (suits to fixed-link) and not an in-band?
> Yes, I could think about I2C or SPI PHYs that you could use alongside=
 an
> Ethernet controller that would qualify for out-of-band, not in-band, =
yet
> could still provide auto-negotiation. You may have special hardware w=
ith
> such a SPI or I2C controller which provides automatic decoding of the
> auto-neg registers. Have not looked at e.g: SFP form factors or fiber
> links, but they could also have additional out-of-band type of
> auto-negotiation available.
>
>> If the answer is yes (even theoretically), then
>> autoneg =3D "in-band" | "off"
>> may make sense. Otherwise boolean just looks enough.
> I think the answer is yes.
>
>> If we would implement autoneg outside of the fixed-link,
>> then its semantic would likely be
>> autoneg =3D "mdio" | "in-band" | "off"
>> But the fact that we put it under fixed-link where only a
>> single AN possibility exist, may probably be underlined by
>> a semantic specific to fixed-link.
> Right, if auto-negotiation was defined outside of fixed-link, that is
> indeed how I would also specify this.
Hmm, okey.
But then this all doesn't fit into a fixed-link. The inband autoneg
is a very small xtension, it only allows to notify MAC about some
changes on the other end, but never control such changes, so
from some POV it is still pretty much fixed. And it also built into
the protocols that fixed-link already use, so that looked like a
natural xtension to me. But if there are so many possible ways
to abuse fixed-link making it _fully managed_, I am really starting
to think about the possibility of defining the autoneg outside of it,
and leave the poor fixed-link alone.
The patch will be bigger, but... what do you think?
This will of course first require defining the fixed-link in the
docs more strictly, as currently it is (vaguely) defined as
"non-MDIO", which leaves a lot to speculate and abuse.
