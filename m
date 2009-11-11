From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 10/10] CAN: use dev_get_by_index_rcu
Date: Wed, 11 Nov 2009 06:54:24 +0100
Message-ID: <4AFA5190.60600@hartkopp.net>
References: <20091110175446.280423729@vyatta.com> <20091110175647.824581805@vyatta.com> <4AF9B21E.50805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:17006 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbZKKFyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 00:54:23 -0500
In-Reply-To: <4AF9B21E.50805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>> Use new function to avoid doing read_lock().
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> --- a/net/can/bcm.c	2009-11-10 09:45:16.301376272 -0800
>> +++ b/net/can/bcm.c	2009-11-10 09:46:30.125005956 -0800
>> @@ -139,13 +139,13 @@ static char *bcm_proc_getifname(char *re
>>  	if (!ifindex)
>>  		return "any";
>> =20
>> -	read_lock(&dev_base_lock);
>> -	dev =3D __dev_get_by_index(&init_net, ifindex);
>> +	rcu_read_lock();
>> +	dev =3D dev_get_by_index_rcu(&init_net, ifindex);
>>  	if (dev)
>>  		strcpy(result, dev->name);
>>  	else
>>  		strcpy(result, "???");
>> -	read_unlock(&dev_base_lock);
>> +	rcu_read_unlock();
>> =20
>>  	return result;
>>  }
>>
>=20
> I was pretty sure I had already done this one...
>=20
> Ah yes, that was planned after a bugfix for net-2.6.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20

Thanks everyone!

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
