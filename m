From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: dsa: Add support for parsing the old
 binding
Date: Sun, 5 Jun 2016 15:42:14 -0700
Message-ID: <5754AAC6.3080701@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
 <20160604200016.GD2063@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33048 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbcFEWmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 18:42:17 -0400
Received: by mail-oi0-f66.google.com with SMTP id f12so7869132oig.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 15:42:16 -0700 (PDT)
In-Reply-To: <20160604200016.GD2063@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/06/2016 13:00, Andrew Lunn a =C3=A9crit :
>> -static int dsa_cpu_parse(struct device_node *port, u32 index,
>> -			 struct dsa_switch_tree *dst,
>> -			 struct dsa_switch *ds)
>> +static int _dsa_cpu_parse(struct dsa_switch_tree *dst,
>> +			   struct dsa_switch *ds,
>> +			   struct net_device *ethernet_dev,
>> +			   u32 index)
>>  {
>> -	struct net_device *ethernet_dev;
>> -	struct device_node *ethernet;
>> -
>> -	ethernet =3D of_parse_phandle(port, "ethernet", 0);
>> -	if (!ethernet)
>> -		return -EINVAL;
>> -
>> -	ethernet_dev =3D of_find_net_device_by_node(ethernet);
>> -	if (!ethernet_dev)
>> -		return -EPROBE_DEFER;
>> -
>=20
> Hi Florian
>=20
> You have just removed all the actual DT parsing. So i would give this
> a different name, and avoid the _ prefix.
>=20
>> +static int _dsa_register_switch_legacy(struct dsa_switch *ds, struc=
t device_node *np)
>> +{
>=20
> We might want to call this _dsa_register_switch_legacy_sf2, since the
> code only supports what is needed for your rather odd sf2 binding.

The SF2 binding just encapsulates the normal legacy DSA binding in its
simplified, one switch only configuration, that makes things much
easier, but not way off.

> It does not appear to work for the generic DSA binding.

It would if we also added support for parsing and filing in a routing
table, so yes, that is currently missing.

How about offering dsa_of_parse() (or another name) as a helper functio=
n
which fills up a dsa_switch / dsa_switch_tree structure to the best it
can, and then let a driver dealing with the old binding call into the
bottom parts of dsa_register_switch()? That could allow us to remove
some of the duplicated code from net/dsa/dsa.c by doing so

The other approach could be to have custom DT parsing in bcm_sf2.c and
also call the bottom parts of dsa_register_switch() once it has properl=
y
initialized ds/dst.

How much support do we want to have for the old binding for in tree
platforms? Is the plan to migrate them all to the new binding?

--=20
=46lorian
