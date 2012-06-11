From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 1/3] bonding:record primary when modify it via sysfs
Date: Mon, 11 Jun 2012 13:48:54 -0700
Message-ID: <31624.1339447734@death.nxdomain>
References: <cover.1339404887.git.wpan@redhat.com> <84a4e0e6bbdc9206baefb1454324f4759a98b80e.1339404887.git.wpan@redhat.com> <4FD64938.6080009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiping Pan <wpan@redhat.com>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:33359 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab2FKUuP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 16:50:15 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 11 Jun 2012 14:50:15 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 212B03E40060
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 20:49:11 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5BKmunM140166
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 14:49:05 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BKmuqb022679
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 14:48:56 -0600
In-reply-to: <4FD64938.6080009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
>> If we modify primary via sysfs and it is not a valid slave,
>> we should record it for future use, and this behavior is the same wi=
th
>> bond_check_params().
>>
>> Signed-off-by: Weiping Pan<wpan@redhat.com>
>> ---
>>   drivers/net/bonding/bond_sysfs.c |    8 ++++++--
>>   1 files changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/=
bond_sysfs.c
>> index aef42f0..485bedb 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -1082,8 +1082,12 @@ static ssize_t bonding_store_primary(struct d=
evice *d,
>>   		}
>>   	}
>>
>> -	pr_info("%s: Unable to set %.*s as primary slave.\n",
>> -		bond->dev->name, (int)strlen(buf) - 1, buf);
>> +	strncpy(bond->params.primary, ifname, IFNAMSIZ);
>> +	bond->params.primary[IFNAMSIZ - 1] =3D 0;
>> +
>> +	pr_info("%s: Recording %s as primary, "
>> +		"but it has not been enslaved to %s yet.\n",
>> +		bond->dev->name, ifname, bond->dev->name);
>>   out:
>>   	write_unlock_bh(&bond->curr_slave_lock);
>>   	read_unlock(&bond->lock);
>
>I like this one, because it tend to relax the current constraints one
>should respect on the order to write into sysfs to setup bonding.
>
>May I suggest we have a better info message, suggesting there might ha=
ve a
>typo on the name of the primary ?
>
>> +	pr_info("%s: Recording %s as primary, "
>> +		"but it has not been enslaved to %s yet. Possible typo?\n",
>> +		bond->dev->name, ifname, bond->dev->name);
>
>Except from this cosmetic,
>
>Acked-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>

	Agreed, except that I can go either way on the "typo" warning.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
