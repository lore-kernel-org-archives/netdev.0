From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net 2/3] bonding:check mode when modify primary_reselect
Date: Mon, 11 Jun 2012 23:13:28 +0200
Message-ID: <4FD65F78.2070001@gmail.com>
References: <cover.1339404887.git.wpan@redhat.com> <5cef8fed5c7fbb9e7f18e61a2c9a47b45f87ca0d.1339404887.git.wpan@redhat.com> <4FD64A19.8000003@gmail.com> <31758.1339448166@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiping Pan <wpan@redhat.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33125 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2FKVMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 17:12:34 -0400
Received: by eaak11 with SMTP id k11so1971587eaa.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 14:12:33 -0700 (PDT)
In-Reply-To: <31758.1339448166@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/06/2012 22:56, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
>>> Using a primary_reselect only makes sense in active backup, TLB or =
ALB modes.
>>>
>>> Signed-off-by: Weiping Pan<wpan@redhat.com>
>>> ---
>>>    drivers/net/bonding/bond_sysfs.c |    7 +++++++
>>>    1 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding=
/bond_sysfs.c
>>> index 485bedb..1b0f3cd 100644
>>> --- a/drivers/net/bonding/bond_sysfs.c
>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>> @@ -1123,6 +1123,13 @@ static ssize_t bonding_store_primary_reselec=
t(struct device *d,
>>>    	if (!rtnl_trylock())
>>>    		return restart_syscall();
>>>
>>> +	if (!USES_PRIMARY(bond->params.mode)) {
>>> +		pr_err("%s: Unable to set primary_reselect; %s is in mode %d\n",
>>> +			bond->dev->name, bond->dev->name, bond->params.mode);
>>> +		ret =3D -EINVAL;
>>> +		goto out;
>>> +	}
>>> +
>>>    	new_value =3D bond_parse_parm(buf, pri_reselect_tbl);
>>>    	if (new_value<   0)  {
>>>    		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
>>
>>
>> May I suggest we only issue a warning, store the new value for
>> primary_reselect, and avoid calling bond_select_active_slave(bond), =
if
>> !USE_PRIMARY(bond->params.mode)?
>>
>> That way, we do not add one more constraint on the order one must wr=
ite into sysfs.
>
> 	I'm not in favor of changing anything here.  There's already a
> message that primary_reselect is being changed, I think that's
> sufficient.  The other similar cases don't issue warnings, e.g., sett=
ing
> xmit_hash_policy doesn't complain if the mode is not one that utilize=
s
> the hash.

Agreed. Calling bond_select_active_slave(bond) looks safe, even for mod=
e that does not use primary,=20
so we don't need to change anything.

Would you support other patch similar to 1/3 in this thread, that try t=
o relax the order to write=20
into sysfs for bonding?

	Nicolas
