From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net 1/3] bonding:record primary when modify it via sysfs
Date: Tue, 12 Jun 2012 22:05:37 +0200
Message-ID: <4FD7A111.9040004@gmail.com>
References: <cover.1339404887.git.wpan@redhat.com> <84a4e0e6bbdc9206baefb1454324f4759a98b80e.1339404887.git.wpan@redhat.com> <4FD64938.6080009@gmail.com> <31624.1339447734@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, Weiping Pan <wpan@redhat.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47716 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab2FLUEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 16:04:45 -0400
Received: by eaak11 with SMTP id k11so2325404eaa.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 13:04:44 -0700 (PDT)
In-Reply-To: <31624.1339447734@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/06/2012 22:48, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
>>> If we modify primary via sysfs and it is not a valid slave,
>>> we should record it for future use, and this behavior is the same w=
ith
>>> bond_check_params().
>>>
>>> Signed-off-by: Weiping Pan<wpan@redhat.com>
>>> ---
>>>    drivers/net/bonding/bond_sysfs.c |    8 ++++++--
>>>    1 files changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding=
/bond_sysfs.c
>>> index aef42f0..485bedb 100644
>>> --- a/drivers/net/bonding/bond_sysfs.c
>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>> @@ -1082,8 +1082,12 @@ static ssize_t bonding_store_primary(struct =
device *d,
>>>    		}
>>>    	}
>>>
>>> -	pr_info("%s: Unable to set %.*s as primary slave.\n",
>>> -		bond->dev->name, (int)strlen(buf) - 1, buf);
>>> +	strncpy(bond->params.primary, ifname, IFNAMSIZ);
>>> +	bond->params.primary[IFNAMSIZ - 1] =3D 0;
>>> +
>>> +	pr_info("%s: Recording %s as primary, "
>>> +		"but it has not been enslaved to %s yet.\n",
>>> +		bond->dev->name, ifname, bond->dev->name);
>>>    out:
>>>    	write_unlock_bh(&bond->curr_slave_lock);
>>>    	read_unlock(&bond->lock);
>>
>> I like this one, because it tend to relax the current constraints on=
e
>> should respect on the order to write into sysfs to setup bonding.
>>
>> May I suggest we have a better info message, suggesting there might =
have a
>> typo on the name of the primary ?
>>
>>> +	pr_info("%s: Recording %s as primary, "
>>> +		"but it has not been enslaved to %s yet. Possible typo?\n",
>>> +		bond->dev->name, ifname, bond->dev->name);
>>
>> Except from this cosmetic,
>>
>> Acked-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@free.fr>
>
> 	Agreed, except that I can go either way on the "typo" warning.
>
> Signed-off-by: Jay Vosburgh<fubar@us.ibm.com>

David,

I think this patch (http://patchwork.ozlabs.org/patch/164100/) was erro=
neously flagged as "Changes=20
Requested". Despite my suggestion to add a "possible typo" warning, I a=
cked the patch and so do Jay.=20
We eventually decided not to add the "possible typo" warning, so the pa=
tch should be accepted.

Thanks,

	Nicolas.
