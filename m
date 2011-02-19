From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 15:32:44 +0100
Message-ID: <4D5FD48C.5060701@gmail.com>
References: <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com> <20110218.120656.104048936.davem@davemloft.net> <20110218205832.GE2602@psychotron.redhat.com> <21593.1298070371@death> <20110219080523.GB2782@psychotron.redhat.com> <4D5FA1D7.4050801@gmail.com> <20110219110830.GD2782@psychotron.redhat.com> <20110219112842.GE2782@psychotron.redhat.com> <4D5FC308.9020507@gmail.com> <20110219134645.GF2782@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f52.google.com ([209.85.214.52]:40167 "EHLO
	mail-bw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab1BSOct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 09:32:49 -0500
Received: by bwz4 with SMTP id 4so4344673bwz.11
        for <netdev@vger.kernel.org>; Sat, 19 Feb 2011 06:32:48 -0800 (PST)
In-Reply-To: <20110219134645.GF2782@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/02/2011 14:46, Jiri Pirko a =E9crit :
> Sat, Feb 19, 2011 at 02:18:00PM CET, nicolas.2p.debian@gmail.com wrot=
e:

[snip]
>> Inside the loop, we should only do exact match delivery, for
>> &ptype_all and for&ptype_base[ntohs(type)&  PTYPE_HASH_MASK]:
>>
>>         list_for_each_entry_rcu(ptype,&ptype_all, list) {
>> -               if (!ptype->dev || ptype->dev =3D=3D dev) {
>> +               if (ptype->dev =3D=3D dev) {
>>                         if (pt_prev)
>>                                 ret =3D deliver_skb(skb, pt_prev, or=
ig_dev);
>>                         pt_prev =3D ptype;
>>                 }
>>         }
>>
>>
>>         list_for_each_entry_rcu(ptype,
>>                         &ptype_base[ntohs(type)&  PTYPE_HASH_MASK], =
list) {
>>                 if (ptype->type =3D=3D type&&
>> -                   (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=
=3D skb->dev)) {
>> +                   (ptype->dev =3D=3D skb->dev)) {
>>                         if (pt_prev)
>>                                 ret =3D deliver_skb(skb, pt_prev, or=
ig_dev);
>>                         pt_prev =3D ptype;
>>                 }
>>         }
>>
>> After leaving the loop, we can do wilcard delivery, if skb is not NU=
LL.
>>
>>         list_for_each_entry_rcu(ptype,&ptype_all, list) {
>> -               if (!ptype->dev || ptype->dev =3D=3D dev) {
>> +               if (!ptype->dev) {
>>                         if (pt_prev)
>>                                 ret =3D deliver_skb(skb, pt_prev, or=
ig_dev);
>>                         pt_prev =3D ptype;
>>                }
>>         }
>>
>>
>>         list_for_each_entry_rcu(ptype,
>>                         &ptype_base[ntohs(type)&  PTYPE_HASH_MASK], =
list) {
>> -               if (ptype->type =3D=3D type&&
>> -                   (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=
=3D skb->dev)) {
>> +		if (ptype->type =3D=3D type&&  !ptype->dev) {
>>                         if (pt_prev)
>>                                 ret =3D deliver_skb(skb, pt_prev, or=
ig_dev);
>>                         pt_prev =3D ptype;
>>                 }
>>         }
>>
>> This would reduce the number of tests inside the
>> list_for_each_entry_rcu() loops. And because we match only ptype->de=
v
>> =3D=3D dev inside the loop and !ptype->dev outside the loop, this sh=
ould
>> avoid duplicate delivery.
>
> Would you care to put this into patch so I can see the whole picture?
> Thanks.

I will try.

	Nicolas.
