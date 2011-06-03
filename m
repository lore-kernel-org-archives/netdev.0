From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Fri, 03 Jun 2011 21:42:47 +0200
Message-ID: <4DE93937.7070305@ahsoftware.de>
References: <4DE93422.3070000@ahsoftware.de> <1307129642.2600.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307129642.2600.2.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.06.2011 21:34, schrieb Eric Dumazet:
> Le vendredi 03 juin 2011 =C3=A0 21:21 +0200, Alexander Holler a =C3=A9=
crit :
>> Hello,
>>
>> I'm getting a oops in the bridge code in br_change_mtu() with 2.6.39=
=2E1.
>> The patch below seems to fix that.
>>
>> I'm not sure about the usage of dst_cow_metrics_generic() in
>> fake_dst_ops, but after having a quick look at it seems to be ok to =
use
>> that here.
>>
>> Regards,
>>
>> Alexander
>>
>> -----
>>   From 3c1d5951af73389798afeea672ec224e195b8e8d Mon Sep 17 00:00:00 =
2001
>> From: Alexander Holler<holler@ahsoftware.de>
>> Date: Fri, 3 Jun 2011 20:43:06 +0200
>> Subject: [PATCH] bridge: add dst_cow_metrics_generic to fake_dst_ops
>>
>> Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
>> should prevent, it introduces NULL a dereference.
>>
>
> I cant find this commit in known trees. Could you give the real commi=
t
> id and its title ?
>
>> The above commit uses dst_init_metrics() which sets the metrics as
>> read only. As result br_change_mtu() dies in dst_metric_set()
>> which calls dst_metrics_write_ptr() which calls
>> dst->ops->cow_metrics() if the metrics are read only.
>> ---
>>    net/bridge/br_netfilter.c |    1 +
>>    1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> index 5f9c091..de982a1 100644
>> --- a/net/bridge/br_netfilter.c
>> +++ b/net/bridge/br_netfilter.c
>> @@ -107,6 +107,7 @@ static void fake_update_pmtu(struct dst_entry *d=
st,
>> u32 mtu)
>>    static struct dst_ops fake_dst_ops =3D {
>>           .family =3D               AF_INET,
>>           .protocol =3D             cpu_to_be16(ETH_P_IP),
>> +       .cow_metrics =3D          dst_cow_metrics_generic,
>>           .update_pmtu =3D          fake_update_pmtu,
>>    };
>>
>
> Your patch is mangled (white spaces instead of tabulations)

The patch had a tab, so either c&p failed or something else removed the=
=20
tab. Maybe Thunderbird, don't know. Normally I'm using git send-email.

If someone gives a feedback about the content and not the style, I'm=20
willing to send a nice patch which too includes the forgotten Signed-of=
f-by.

Regards,

Alexander
