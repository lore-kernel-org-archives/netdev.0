From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 25/28] Documentation: DSA: Describe how probe of DSA
 and switches work.
Date: Thu, 24 Dec 2015 17:29:58 -0800
Message-ID: <567C9C16.5020005@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-26-git-send-email-andrew@lunn.ch>
 <567B089C.7030108@gmail.com> <20151223225322.GE25485@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33938 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbbLYBaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 20:30:01 -0500
Received: by mail-oi0-f51.google.com with SMTP id o124so144018307oia.1
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 17:30:00 -0800 (PST)
In-Reply-To: <20151223225322.GE25485@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 14:53, Andrew Lunn a =C3=A9crit :
> On Wed, Dec 23, 2015 at 12:48:28PM -0800, Florian Fainelli wrote:
>> Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
>>> With the introduction of switches as linux devices and the use of t=
he
>>> component framework, probing has become more complex. Add some
>>> documentation.
>>>
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>> ---
>>>  Documentation/networking/dsa/dsa.txt | 48 ++++++++++++++++++++++++=
++++++++++++
>>>  1 file changed, 48 insertions(+)
>>>
>>> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/n=
etworking/dsa/dsa.txt
>>> index aa9c1f9313cd..376afa135a81 100644
>>> --- a/Documentation/networking/dsa/dsa.txt
>>> +++ b/Documentation/networking/dsa/dsa.txt
>>> @@ -398,6 +398,54 @@ Switch configuration
>>>    on the management interface and "hardcode"/"force" this MAC addr=
ess for the
>>>    CPU/management interface as an optimization
>>> =20
>>> +Call flow
>>> +---------
>>> +
>>> +With the ability for switch devices to be true linux devices, the =
call
>>> +flow is somewhat complex. The component framework is used to link =
the
>>> +dsa framework as the master, with switch devices, as slaves.
>>> +
>>> +A switch device should add itself as a component in its probe
>>> +function.
>>> +
>>> +The DSA framework can either be configured using a platform_data
>>> +structure or from the device tree. If device tree is being used, t=
he
>>> +dsa framework probe function will allocate a platform_data structu=
re,
>>> +and populate it using the device tree, via the dsa_of_probe()
>>> +function.  Within the DSA device tree, switch devices are represen=
ted
>>> +by a phandle to the switch device. These phandles are saved into t=
he
>>> +platform data so that when switch slaves register themselves, they=
 can
>>> +be correctly positioned in the DSA cluster.
>>
>> Humm, I guess I am still not clear on that, in a DT-only system, do =
I
>> still need to get the DSA platform device to be probed via DT, along
>> with references to the switches I want? If that is the case, that se=
ems
>> a little awkward, could not we probe the individual switches, and se=
e if
>> they need DSA instead? Or is that how the component framework works,
>> just being a bit confused here.
>=20
> The component framework needs one master device and a number of slave
> devices. The master device effectively gives the framework a list of
> slave devices it needs. When the slave devices probe they register
> with the component framework. The master then asks the framework if
> its slaves are present, and if not returns -EPRODE_DEFERS and tries
> again later.
>=20
> So the dsa platform device is the master, and the switch devices are
> the slaves.

Ok, but then that means I still need to have a "marvell,dsa" node in
Device Tree, that does not make sense to me with your changes, because
the individual compatible and nodes for the switches are enough
information to get their driver to probe, and as a consequence, registe=
r
with DSA their switch devices, but let's keep following this point in
the cover letter thread.

>=20
> It sounds like you want to 'optimise' for a DSA cluster consisting of
> a single switch, throwing away the D in DSA. Now the SF2 is a bit
> 'odd'. Since it is embedded in the SoC, you cannot have multiple of
> them in a cluster. So such an optimization could make sense for the
> SF2. But can we do this without adding too more complexity?

The distributed case is the complex one, the one with a single switch
hanging off an Ethernet MAC is the most common one and is much simpler
to deal with.
--=20
=46lorian
