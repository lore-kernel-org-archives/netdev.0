From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/9] dsa: mv88e6xxx: Set the RGMII delay based
 on phy interface
Date: Mon, 24 Aug 2015 10:01:38 -0700
Message-ID: <55DB4DF2.7020502@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-7-git-send-email-andrew@lunn.ch> <55DA1471.2080905@gmail.com> <20150823211014.GC20710@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33579 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbbHXREI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:04:08 -0400
Received: by pdrh1 with SMTP id h1so56546408pdr.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:04:08 -0700 (PDT)
In-Reply-To: <20150823211014.GC20710@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/08/15 14:10, Andrew Lunn wrote:
> On Sun, Aug 23, 2015 at 11:44:01AM -0700, Florian Fainelli wrote:
>> Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
>>> Some Marvell switches allow the RGMII Rx and Tx clock to be delayed
>>> when the port is using RGMII. Have the adjust_link function look at
>>> the phy interface type and enable this delay as requested.
>>>
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>> ---
>>>  drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
>>>  drivers/net/dsa/mv88e6xxx.h |  2 ++
>>>  2 files changed, 12 insertions(+)
>>>
>>> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xx=
x.c
>>> index 7901db6503b4..f5af368751b2 100644
>>> --- a/drivers/net/dsa/mv88e6xxx.c
>>> +++ b/drivers/net/dsa/mv88e6xxx.c
>>> @@ -612,6 +612,16 @@ void mv88e6xxx_adjust_link(struct dsa_switch *=
ds, int port,
>>>  	if (phydev->duplex =3D=3D DUPLEX_FULL)
>>>  		reg |=3D PORT_PCS_CTRL_DUPLEX_FULL;
>>> =20
>>> +	if ((mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds)) &&
>>> +	    (port >=3D ps->num_ports - 2)) {
>>
>> Are we positive that the last two ports of a switch are going to be
>> RGMII capable or is this something that should be moved to Device Tr=
ee /
>> platform data to account for different switch families? Maybe having=
 a
>> bitmask of RGMII capable ports stored in "ps" would be good enough?
>=20
> Hi Florian
>=20
> For these two families, this is correct. And it is a property of the
> switch, not the board, so should not be in DT. Other families are
> different. Older ones are Fast Ethernet only. Some don't have any
> RGMII ports, etc. It could be with time, this condition gets messy, a=
t
> which point, a bitmask in ps would make sense. But is it justified
> now?

Sure, I think for now this patch is good as-is, I was mostly curious
whether the assumption about the last 2 ports of the switch being RGMII
would hold for a while, and it looks like it will. With that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
