From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net] bonding: add ip checks when store ip target
Date: Tue, 12 Nov 2013 23:46:43 +0800
Message-ID: <52824D63.9050609@gmail.com>
References: <52821024.6050607@huawei.com> <20131112113610.GB19702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:59136 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab3KLP5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 10:57:35 -0500
Received: by mail-pb0-f51.google.com with SMTP id xa7so7065678pbc.24
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 07:57:34 -0800 (PST)
In-Reply-To: <20131112113610.GB19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/12 19:36, Veaceslav Falico =E5=86=99=E9=81=93:
> On Tue, Nov 12, 2013 at 07:25:24PM +0800, Ding Tianhong wrote:
>> I met a Bug when I add ip target with the wrong ip address:
>>
>> echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target
>>
>> the wrong ip address will transfor to 245.245.245.244 and add
>> to the ip target success, it is uncorrect, so I add checks to avoid
>> adding wrong address.
>>
>> The in4_pton() will set wrong ip address to 0.0.0.0, it will return =
by
>> the next check and will not add to ip target.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_sysfs.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> Your mail client, apparently, transformed tabs into spaces, so the pa=
tch
> doesn't apply.
>
yes, the patch was made in net-next, I forget to make it in net, I'll=20
send it by office mail in office later.
Thanks.
Regards
Ding
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c=20
>> b/drivers/net/bonding/bond_sysfs.c
>> index 4838a97..5b7bf37 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -612,7 +612,7 @@ static ssize_t bonding_store_arp_targets(struct=20
>> device *d,
>> return restart_syscall();
>>
>> targets =3D bond->params.arp_targets;
>> - newtarget =3D in_aton(buf + 1);
>> + in4_pton(buf + 1, strlen(buf) - 1, (u8 *)&newtarget, -1, NULL);
>> /* look for adds */
>> if (buf[0] =3D=3D '+') {
>> if ((newtarget =3D=3D 0) || (newtarget =3D=3D htonl(INADDR_BROADCAST=
))) {
>> --=20
>> 1.8.2.1
>>
>>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
