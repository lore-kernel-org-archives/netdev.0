From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Sat, 07 Feb 2004 12:45:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4024C1D5.5030906@kolumbus.fi>
References: <4023D6FB.9010909@kolumbus.fi>	<20040207.131455.27570445.yoshfuji@linux-ipv6.org>	<4024A488.60203@kolumbus.fi> <20040207.192804.29120956.yoshfuji@linux-ipv6.org> <4024C0EA.1010904@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>, kazunori@miyazawa.org,
        davem@redhat.com, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <4024C0EA.1010904@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Mika Penttil=E4 wrote:

>
>
> YOSHIFUJI Hideaki / ???? wrote:
>
>> In article <4024A488.60203@kolumbus.fi> (at Sat, 07 Feb 2004 10:40:40=20
>> +0200), Mika Penttil=E4 <mika.penttila@kolumbus.fi> says:
>>
>> =20
>>
>>>> The ip6_output2() resolves and inserts link-layer address=20
>>>> appropriately.
>>>> If it did, we would have noticed (by conformance test or even by
>>>> usual operation). ;-)
>>>>
>>>>
>>>>    =20
>>>
>>> ip6_output2() doesn't resolve link-layer addresses. We don't even=20
>>> have a neighbour, in
>>> ndisc_dst_alloc(dev, NULL, ip6_output2); case.
>>>  =20
>>
>>
>> ip6_output2() calls ip6_output_flinish().
>> ip6_output_finish() calls dst->hh->hh_output() if hh is already built.
>> Otherwise, dst->neighbour->output() is called and it resolves=20
>> link-layer address of neighbor.
>>
>> I think you missed our ndsic_dst_alloc() change.
>> ndisc_dst_alloc() takes 4 argument:
>>   struct dst_entry *ndisc_dst_alloc(struct net_device *dev,=20
>>                                     struct neighbour *neigh,
>>                                     struct in6_addr *addr,
>>                                     int (*output)(struct sk_buff *));
>> If neigh is NULL, we do ndisc_get_neigh(dev, addr) to get one.
>>
>> =20
>>
> hmm. where is this ndisc_dst_alloc() change? In the patch it's called=20
> with three params, only the output routine is changed :
>
> - dst =3D ndisc_dst_alloc(dev, NULL, ndisc_output);
> + dst =3D ndisc_dst_alloc(dev, NULL, ip6_output2);
>
>
> --Mika
>
I see, it was in a follow-up patch. Ok, I was just looking at the=20
original patch, which didn't work. But with this ndisc_dst_alloc()=20
change it's ok.

Thanks,
--Mika
