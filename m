From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 7/9] net: dsa: Initialize CPU port ethtool ops
 per tree
Date: Sun, 5 Jun 2016 15:29:01 -0700
Message-ID: <5754A7AD.1020208@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-11-git-send-email-f.fainelli@gmail.com>
 <20160604203855.GH2063@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36798 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377AbcFEW3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 18:29:10 -0400
Received: by mail-oi0-f68.google.com with SMTP id n3so5678724oig.3
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 15:29:04 -0700 (PDT)
In-Reply-To: <20160604203855.GH2063@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/06/2016 13:38, Andrew Lunn a =C3=A9crit :
>> index e8386157de30..938262010524 100644
>> --- a/net/dsa/dsa2.c
>> +++ b/net/dsa/dsa2.c
>> @@ -346,7 +346,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *=
dst, struct dsa_switch *ds)
>>  			continue;
>>  	}
>> =20
>> -	return 0;
>> +	return dsa_cpu_port_ethtool_setup(dst, ds);
>=20
> Hi Florian
>=20
> This is wrong. Remember, multiple CPU ports. You need to apply this t=
o
> each CPU port.

We do not quite support that properly though, we still do not create a
"cpu" network device, and there is only a single master netdev per
dsa_switch at the moment, making the secondary CPU port interfaces
impossible to overlay their backing "master" netdev with their companio=
n
switch port statistics at the moment.

This fixes a real bug where we end-up clobbering
dsa_cpu_port_ethtool_ops as soon as there are multiple trees being
registered, and this can now happen.
--=20
=46lorian
