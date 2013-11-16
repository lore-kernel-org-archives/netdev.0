From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net] bonding: set primary_reselect in LB and AB mode
Date: Sat, 16 Nov 2013 09:50:42 +0800
Message-ID: <5286CF72.20406@gmail.com>
References: <5285F130.5060705@huawei.com> <4031.1384538565@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:57033 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab3KPCBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:01:34 -0500
Received: by mail-pa0-f44.google.com with SMTP id fb1so2767549pad.3
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 18:01:33 -0800 (PST)
In-Reply-To: <4031.1384538565@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2013/11/16 2:02, Jay Vosburgh =D0=B4=B5=C0:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
>
>> The primary_reselect only reselection for the primary slave,
>> but the primary slave only support for ALB, TLB and AB mode,
>> so we sould set the primary_reselect for these mode.
>>
>> to fix this: Add a check for ALB, TLB and AB mode in
>> bonding_store_primary_reselect, avoid to select active slave
>> again in other modes.
> 	I don't believe that setting primary_reselect in a
> !USES_PRIMARY() mode has any negative effects.  It doesn't do anythin=
g,
> but also doesn't break anything.  Is there a case that setting
> primary_reselect causes misbehavior in a !USES_PRIMARY() mode?

I see it will call bond_select_active_slave and I will think more about=
 it,
if I could not find any problem about it, will miss this patch.
thanks.

Regards
Ding


> 	Presuming that primary_reselect doesn't break things, this just
> adds an ordering limitation when configuring bonding (mode must be se=
t
> prior to primary_reselect).  I don't believe this change adds any val=
ue,
> and may break existing configuration scripts.
>
> 	-J
>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_sysfs.c | 7 +++++++
>> 1 file changed, 7 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/=
bond_sysfs.c
>> index 47749c9..cac2291 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -1141,6 +1141,13 @@ static ssize_t bonding_store_primary_reselect=
(struct device *d,
>> 	if (!rtnl_trylock())
>> 		return restart_syscall();
>>
>> +	if (!USES_PRIMARY(bond->params.mode)) {
>> +		pr_info("%s: Unable to set primary reselect; %s is in mode %d\n",
>> +			bond->dev->name, bond->dev->name, bond->params.mode);
>> +		ret =3D -EINVAL;
>> +		goto out;
>> +	}
>> +
>> 	new_value =3D bond_parse_parm(buf, pri_reselect_tbl);
>> 	if (new_value < 0)  {
>> 		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
>> --=20
>> 1.7.12

> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
