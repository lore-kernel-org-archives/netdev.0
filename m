From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATH] dev: reusing unregistered ifindex values in net_device
Date: Thu, 18 Nov 2010 16:43:30 +0100
Message-ID: <AANLkTi=p84Y3o+AgUX-59nvGzqZacm8nR0-GvstR6KmO@mail.gmail.com>
References: <AANLkTinx6Ww4ZwRUTyYD_STPSRsSFck8O=W5yeJSbBs_@mail.gmail.com> <1290094628.2781.195.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Voravit T." <voravit@kth.se>,
	Robert Olsson <robert@herjulf.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65231 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759233Ab0KRPnw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 10:43:52 -0500
Received: by fxm10 with SMTP id 10so35338fxm.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 07:43:51 -0800 (PST)
In-Reply-To: <1290094628.2781.195.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok,
thanks you for you quick response.

//Daniel



On Thu, Nov 18, 2010 at 16:37, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Le jeudi 18 novembre 2010 =E0 16:25 +0100, Daniel Turull a =E9crit :
>> When a new index is going to be assigned in register_netdevice,
>> the dev_new_index starts to search possible values from the last ind=
ex
>> given to a device although there might be some free ifindex that has=
 been
>> previously unregistered. =A0This behaviour may create gap(s) in the =
ifindex list.
>>
>> This patch checks for unused values from 1 and gives to the new devi=
ce the
>> first available value. This limits the maximum ifindex to a smaller =
value.
>>
>> The ifindex will still be unique since the old value is no longer in=
 use.
>>
>> Reported-by: Voravit Tanyingyong =A0<voravit@kth.se>
>> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>>
>> ---
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 381b8e2..a7babab 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4871,7 +4871,7 @@ int dev_ioctl(struct net *net, unsigned int cm=
d,
>> void __user *arg)
>> =A0 */
>> =A0static int dev_new_index(struct net *net)
>> =A0{
>> - =A0 =A0 static int ifindex;
>> + =A0 =A0 int ifindex;
>> =A0 =A0 =A0 for (;;) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (++ifindex <=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ifindex =3D 1;
>> --
>
> NACK
>
> Two bugs
>
> 1) ifindex is not initialized : you'll be suprised of random values
>
> 2) ifindex should not be reused. You'll be surprised so applications =
can
> break. SNMP comes to mind.
>
>
>
>
