From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 06:27:18 -0700 (PDT)
Message-ID: <20100602.062718.163251384.davem@davemloft.net>
References: <1275481538.14363.10.camel@bigi>
	<20100602.054520.228955151.davem@davemloft.net>
	<AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754219Ab0FBN1I convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 09:27:08 -0400
In-Reply-To: <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 2 Jun 2010 21:14:55 +0800

> On Wed, Jun 2, 2010 at 8:45 PM, David Miller <davem@davemloft.net> wr=
ote:
>> From: jamal <hadi@cyberus.ca>
>> Date: Wed, 02 Jun 2010 08:25:38 -0400
>>
>>> --- a/net/sched/cls_u32.c
>>> +++ b/net/sched/cls_u32.c
>>> @@ -135,6 +135,9 @@ next_knode:
>>>
>>> =A0for (i =3D n->sel.nkeys; i>0; i--, key++) {
>>>
>>> + =A0 =A0 =A0 =A0int toff =3D key->off+(off2&key->offmask)- 4;
>>> + =A0 =A0 =A0 =A0if (unlikely(toff > skb->len))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0/* bailout here - needs some thought *=
/
>>> =A0 =A0 =A0 =A0 =A0if ((*(__be32*)(ptr+key->off+(off2&key->offmask)=
)^key->v
>>
>> I don't think it's that simple.
>>
>> You can't dereference from the skb->data linear area if your offset =
is
>> beyond "skb->len - skb->data_len" (aka. skb_headlen()) since that's
>> where the paged or fragmented portion starts.
>>
>> We really need to use skb_copy_bits() if we want to allow
>> any offset into the SKB, and because of all the ways
>> packets can be transformed and constructed we absolutely
>> have to.
>>
>=20
> Maybe skb_header_pointer() is lighter.

Yes, it should be.  In fact, it's designed for this kind of situation
and that's why it's used extensively in netfilter.
