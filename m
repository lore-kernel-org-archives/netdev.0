From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: v3 for tcp friends?
Date: Wed, 23 Jan 2013 21:16:58 +0800
Message-ID: <50FFE2CA.5080801@gmail.com>
References: <20120903.154833.1547153833820955116.davem@davemloft.net>  <CAEkNxbGJ6OGy3HDSeToXO_cDt7azpRZvy_CbQH0_UJ_mCS2s3w@mail.gmail.com>  <20120904.125841.2293649688957878987.davem@davemloft.net>  <50FCEE64.80203@gmail.com> <50FCEEC5.9010404@gmail.com>  <CA+WLrf8xuJ3UXK-tZQykuTPMXu67WsNKWNuNzBKk7MBAidW-CQ@mail.gmail.com>  <CAEkNxbH0MAAU9oiwwrFTbMJP1yzfNdxD5NDdZOqGnvhTLvodoQ@mail.gmail.com>  <50FF5592.60008@gmail.com>  <50FF7F64.2060902@gmail.com> <1358923606.12374.746.camel@edumazet-glaptop> <50FF8F75.4000903@gmail.com> <50FF9836.4060106@gmail.com> <50FFAFE7.5030707@gmail.com> <50FFB2D2.4050603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Bruce Curtis <brutus@google.com>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35237 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3AWNQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 08:16:50 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so4754749pad.3
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 05:16:50 -0800 (PST)
In-Reply-To: <50FFB2D2.4050603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 05:52 PM, Li Yu wrote:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8823=E6=97=A5 17:39, Li Yu =E5=86=99=E9=
=81=93:
>> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8823=E6=97=A5 15:58, Li Yu =E5=86=99=
=E9=81=93:
>>> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8823=E6=97=A5 15:21, Li Yu =E5=86=99=
=E9=81=93:
>>>> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8823=E6=97=A5 14:46, Eric Dumazet =
=E5=86=99=E9=81=93:
>>>>> On Wed, 2013-01-23 at 14:12 +0800, Li Yu wrote:
>>>>>> Oops, this hang is not since TCP friends patch!
>>>>>>
>>>>>> sk_sndbuf_get() is broken by 32 bits integer overflow
>>>>>> because of so large value in net.ipv4.tcp_{rmem,wmem}.
>>>>>>
>>>>>> but this hang also can be found in net-next.git
>>>>>> (3.8.0-rc3+), if we run below commands, then all new
>>>>>> TCP connections stop working!
>>>>>>
>>>>>> # when TCP friends is disabled
>>>>>> sysctl -w net.ipv4.tcp_rmem=3D"4096 4294967296 4294967296" # 4GB
>>>>>> sysctl -w net.ipv4.tcp_wmem=3D"4096 4294967296 4294967296"
>>>>>
>>>>> Right we need to make sure we dont overflow.
>>>>>
>>>>> Try the following fix :
>>>>>
>>>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv=
4.c
>>>>> index a25e1d2..1459145 100644
>>>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>>>> @@ -549,14 +549,16 @@ static struct ctl_table ipv4_table[] =3D {
>>>>>           .data        =3D &sysctl_tcp_wmem,
>>>>>           .maxlen        =3D sizeof(sysctl_tcp_wmem),
>>>>>           .mode        =3D 0644,
>>>>> -        .proc_handler    =3D proc_dointvec
>>>>> +        .extra1        =3D &zero,
>>
>> If we added below:
>>
>> +static int one =3D 1;
>> +static int int_max =3D INT_MAX;
>> ....
>> +               .extra1     =3D &one,
>> +        .extra2        =3D &int_max,
>>
>
> The "int_max" may be unnecessary here :)
Hi, Li Yu,

I tested that your patch works fine.
Can you post a complete patch ?

thanks
Weiping Pan
