From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 2/3] bonding:check mode when modify primary_reselect
Date: Mon, 11 Jun 2012 13:56:06 -0700
Message-ID: <31758.1339448166@death.nxdomain>
References: <cover.1339404887.git.wpan@redhat.com> <5cef8fed5c7fbb9e7f18e61a2c9a47b45f87ca0d.1339404887.git.wpan@redhat.com> <4FD64A19.8000003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiping Pan <wpan@redhat.com>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:50637 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab2FKU46 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 16:56:58 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 11 Jun 2012 14:56:57 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5C2C319D8051
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 20:56:53 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5BKu8s1221102
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 14:56:08 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BKu8KZ027544
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 14:56:08 -0600
In-reply-to: <4FD64A19.8000003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
>> Using a primary_reselect only makes sense in active backup, TLB or A=
LB modes.
>>
>> Signed-off-by: Weiping Pan<wpan@redhat.com>
>> ---
>>   drivers/net/bonding/bond_sysfs.c |    7 +++++++
>>   1 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/=
bond_sysfs.c
>> index 485bedb..1b0f3cd 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -1123,6 +1123,13 @@ static ssize_t bonding_store_primary_reselect=
(struct device *d,
>>   	if (!rtnl_trylock())
>>   		return restart_syscall();
>>
>> +	if (!USES_PRIMARY(bond->params.mode)) {
>> +		pr_err("%s: Unable to set primary_reselect; %s is in mode %d\n",
>> +			bond->dev->name, bond->dev->name, bond->params.mode);
>> +		ret =3D -EINVAL;
>> +		goto out;
>> +	}
>> +
>>   	new_value =3D bond_parse_parm(buf, pri_reselect_tbl);
>>   	if (new_value<  0)  {
>>   		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
>
>
>May I suggest we only issue a warning, store the new value for
>primary_reselect, and avoid calling bond_select_active_slave(bond), if
>!USE_PRIMARY(bond->params.mode)?
>
>That way, we do not add one more constraint on the order one must writ=
e into sysfs.

	I'm not in favor of changing anything here.  There's already a
message that primary_reselect is being changed, I think that's
sufficient.  The other similar cases don't issue warnings, e.g., settin=
g
xmit_hash_policy doesn't complain if the mode is not one that utilizes
the hash.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
