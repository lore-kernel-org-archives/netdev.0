From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/5] net: use ndo_fix_features for
 ethtool_ops->set_flags
Date: Mon, 07 Feb 2011 13:03:15 -0800 (PST)
Message-ID: <20110207.130315.183056273.davem@davemloft.net>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	<bbe7e5742ffe44fb2938b7b6c2c656395fc361ac.1296741562.git.mirq-linux@rere.qmqm.pl>
	<1297107972.4077.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754524Ab1BGVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 16:02:39 -0500
In-Reply-To: <1297107972.4077.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 07 Feb 2011 19:46:12 +0000

> On Thu, 2011-02-03 at 15:21 +0100, Micha=A9=A9 Miros=A9=A9aw wrote:
>> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> ---
>>  net/core/ethtool.c |   31 +++++++++++++++++++++++++++++--
>>  1 files changed, 29 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index 555accf..6e7c6f2 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -240,6 +240,34 @@ static int ethtool_set_features(struct net_devi=
ce *dev, void __user *useraddr)
>>  	return ret;
>>  }
>> =20
>> +static int __ethtool_set_flags(struct net_device *dev, u32 data)
>> +{
>> +	u32 changed;
>> +
>> +	if (data & ~flags_dup_features)
>> +		return -EINVAL;
>> +
>> +	/* legacy set_flags() op */
>> +	if (dev->ethtool_ops->set_flags) {
>> +		if (unlikely(dev->hw_features & flags_dup_features))
>> +			netdev_warn(dev,
>> +				"driver BUG: mixed hw_features and set_flags()\n");
>> +		return dev->ethtool_ops->set_flags(dev, data);
>> +	}
>> +
>> +	/* allow changing only bits set in hw_features */
>> +	changed =3D (data ^ dev->wanted_features) & flags_dup_features;
>> +	if (changed & ~dev->hw_features)
>> +		return -EOPNOTSUPP;
> [...]
>=20
> The error code should only be EOPNOTSUPP if (dev->hw_features &
> flags_dup_features) =3D=3D 0.  Otherwise it should be EINVAL.

I'll fix this up when I apply his patch, thanks Ben.
