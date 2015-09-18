From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 10:30:42 -0700
Message-ID: <55FC4A42.905@gmail.com>
References: <20150917231422.GY21084@n2100.arm.linux.org.uk> <55FBF59E.3010205@list.ru> <20150918121311.GD21084@n2100.arm.linux.org.uk> <55FC070A.6020707@list.ru> <20150918131257.GF21084@n2100.arm.linux.org.uk> <55FC151F.6040708@list.ru> <20150918135746.GG21084@n2100.arm.linux.org.uk> <55FC2387.9080304@list.ru> <20150918154339.GJ21084@n2100.arm.linux.org.uk> <55FC35F9.9040403@list.ru> <20150918172222.GL21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@lunn.ch, David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33307 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348AbbIRRar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:30:47 -0400
Received: by pacex6 with SMTP id ex6so56648417pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:30:47 -0700 (PDT)
In-Reply-To: <20150918172222.GL21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/09/15 10:22, Russell King - ARM Linux wrote:
> On Fri, Sep 18, 2015 at 07:04:09PM +0300, Stas Sergeev wrote:
>> 18.09.2015 18:43, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
>>> On Fri, Sep 18, 2015 at 05:45:27PM +0300, Stas Sergeev wrote:
>>>> AFAICS if it has use_inband_status=3D=3Dtrue,
>>>> then it went through of_phy_register_fixed_link(dn),
>>>
>>> That's totally incorrect.  The test for setting use_inband_status i=
n
>>> mvneta is:
>>>
>>>         err =3D of_property_read_string(dn, "managed", &managed);
>>>         pp->use_inband_status =3D (err =3D=3D 0 &&
>>>                                  strcmp(managed, "in-band-status") =
=3D=3D 0);
>>
>> Arrrr! I was looking at the branch without the last
>> patch applied, so it occurred to me as
>>
>> 	pp->use_inband_status =3D (phy_mode =3D=3D PHY_INTERFACE_MODE_SGMII=
) &&
>> 		fixed_phy;
>>
>> Sorry for that.
>=20
> Yay :)
>=20
>> So we seem to indeed have a nasty regression with the patch
>> that just went to stable. :( Great news.
>=20
> Yes.
>=20
>> Thanks for you time.
>>
>> I still have problems with this part though:
>>> If there's neither a MDIO PHY nor a fixed-link, then the network dr=
iver
>>> fails to initialise the device.
>>
>> I think I am looking into the right source this time, seems like
>> if we don't have both but still have managed=3D"in-band-status", tha=
t
>> should go the fixed-link path and still work... no?
>=20
> If we have no fixed-link and no phy, then you're correct.
>=20
> However, I really don't like the idea of abusing "fixed-link" as a
> method to generate an ethtool/miitool/miidiag compatible output for
> this, but I'm willing to let that pass for the moment. :)

It is not just for that, you get all the goodies from the PHY library
without modifying your Ethernet MAC driver specifically for it:
phy_connect, adjust_link and phy_ethtool_{set,get}.

The solution that was judged being the less intrusive back then was to
provide MII-like registers, getting you all user-land to work
transparently for free, but now that I think about it, having this "MII=
"
translation seems a bit unnecessary, if not confusing. It may be better
to remove some of register update logic and just assign phydev members
directly...
--=20
=46lorian
