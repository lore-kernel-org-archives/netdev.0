From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 2 Jun 2010 21:14:55 +0800
Message-ID: <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
References: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	<1275481219.14363.6.camel@bigi> <1275481538.14363.10.camel@bigi>
	<20100602.054520.228955151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44122 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab0FBNPQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:15:16 -0400
Received: by pvg16 with SMTP id 16so48557pvg.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:15:15 -0700 (PDT)
In-Reply-To: <20100602.054520.228955151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 2, 2010 at 8:45 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: jamal <hadi@cyberus.ca>
> Date: Wed, 02 Jun 2010 08:25:38 -0400
>
>> --- a/net/sched/cls_u32.c
>> +++ b/net/sched/cls_u32.c
>> @@ -135,6 +135,9 @@ next_knode:
>>
>> =A0for (i =3D n->sel.nkeys; i>0; i--, key++) {
>>
>> + =A0 =A0 =A0 =A0int toff =3D key->off+(off2&key->offmask)- 4;
>> + =A0 =A0 =A0 =A0if (unlikely(toff > skb->len))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0/* bailout here - needs some thought */
>> =A0 =A0 =A0 =A0 =A0if ((*(__be32*)(ptr+key->off+(off2&key->offmask))=
^key->v
>
> I don't think it's that simple.
>
> You can't dereference from the skb->data linear area if your offset i=
s
> beyond "skb->len - skb->data_len" (aka. skb_headlen()) since that's
> where the paged or fragmented portion starts.
>
> We really need to use skb_copy_bits() if we want to allow
> any offset into the SKB, and because of all the ways
> packets can be transformed and constructed we absolutely
> have to.
>

Maybe skb_header_pointer() is lighter.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
