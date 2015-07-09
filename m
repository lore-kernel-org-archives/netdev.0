From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 2/2] mvneta: use inband status only when link type is
 "auto"
Date: Fri, 10 Jul 2015 00:31:22 +0300
Message-ID: <559EE82A.60505@list.ru>
References: <559EB0A4.5080101@list.ru> <559EB22E.7070607@list.ru>
 <559EBAFE.6040705@gmail.com> <559ED8F1.7050609@list.ru>
 <559EE423.9060503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <559EE423.9060503@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10.07.2015 00:14, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 09/07/15 13:26, Stas Sergeev wrote:
>> 09.07.2015 21:18, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On 09/07/15 10:41, Stas Sergeev wrote:
>>>> The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band li=
nk
>>>> state
>>>> signaling") implemented the link parameters auto-negotiation
>>>> unconditionally.
>>>> Unfortunately it appears that some HW that implements SGMII protoc=
ol,
>>>> doesn't generate the inband status, so it is not possible to
>>>> auto-negotiate
>>>> anything with such HW.
>>> What is the purpose of using the in-band status in the first place =
if
>>> you end-up having to specify a 'fixed-link' property which contains=
 most
>>> of the link parameters: speed, duplex etc...?
>> You don't have to.
>> My config from today is as simple as:
>>
>> fixed-link {
>>    link =3D "auto";
>> };
>>
>> and that's all.
>> Without my today's patch, only 'speed' is a mandatory - not too much=
=2E
> That makes me think that 'fixed-link' is not exactly what you want th=
en,
> you would probably want something like "marvell,use-in-band-status" o=
r
> something like this. It could be a more generic property that is not
> Marvell specific after all, that would be fine.
I think there is some confusion around fixed-link, because
of its name. This is what fixed-link is:
---
Some Ethernet MACs have a "fixed link", and are not connected to a
normal MDIO-managed PHY device.
---
A bit vague, but to me it means "non-MDIO", and that's all.
If we make it like "marvell,use-in-band-status", then it will
suddenly cancel everything in a fixed-link definition, which
is non obvious. Or, if we make it so that fixed-link def is
not needed in presence of "marvell,use-in-band-status", then
this "marvell,use-in-band-status" will have to silently enable
the fixed-phy driver the way fixed-link does.
If we just view fixed-link as non-MDIO link, then everything
fits, IMHO.
