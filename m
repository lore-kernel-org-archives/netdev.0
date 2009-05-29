From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: changing the qdisc class speed rate
Date: Fri, 29 May 2009 22:34:25 +0200
Message-ID: <4A2046D1.3050402@gmail.com>
References: <50214222-779D-4C49-9151-C725C8F470D5@gmail.com>	 <20090527222158.42f71e28@nehalam> <620d582f0905291203n69bce7bkd2c06d48d27f5003@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Piotrek D <regis44@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:38957 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbZE2UfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 16:35:05 -0400
Received: by bwz22 with SMTP id 22so6368949bwz.37
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 13:35:05 -0700 (PDT)
In-Reply-To: <620d582f0905291203n69bce7bkd2c06d48d27f5003@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Piotrek D wrote, On 05/29/2009 09:03 PM:

> This is what I have done, the  cl->rate->rate.rate refers to the __u3=
2
> rate in htb_class -> qdisc_rate_table -> tc_ratespec .
> What else should I modify to make this work ?
>=20

=46rom include/net/sch_generic.h:

/* Length to Time (L2T) lookup in a qdisc_rate_table, to determine how
   long it will take to send a packet given its size.
 */
static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int=
 pktlen)
{
        int slot =3D pktlen + rtab->rate.cell_align + rtab->rate.overhe=
ad;
        if (slot < 0)
                slot =3D 0;
        slot >>=3D rtab->rate.cell_log;
        if (slot > 255)
                return (rtab->data[255]*(slot >> 8) + rtab->data[slot &=
 0xFF]);
        return rtab->data[slot];
}

This function controls rates and these rtab values matter here.

Jarek P.


>=20
>=20
> W dniu 28 maja 2009 07:21 u=BFytkownik Stephen Hemminger
> <shemminger@vyatta.com> napisa=B3:
>> On Thu, 28 May 2009 07:12:33 +0200
>> Piotr Duszy=F1ski <regis44@gmail.com> wrote:
>>
>>> Hi everyone,
>>>
>>> I am trying to change the rate parameter of HTB class by using this
>>> code from within one of my functions :
>>>
>>>    struct htb_class *cl;
>>>    cl=3Dhtb_find(number,q);
>>>
>>>    cl->rate->rate.rate =3D NEW_RATE_VALUE;
>>>
>>>    TC shows the correct values, but the traffic rate doesn't change=
 a
>>> bit.
>>>    Does anyone have any idea what am I doing wrong ? Maybe there wo=
uld
>>> be a faster way by sending a netlink  message ?
>>>
>>> Piotrek
>> HTB uses a rate table, so if you want the rate to change, you will n=
eed to change the
>> table as well.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


