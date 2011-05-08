From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv5 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Sun, 8 May 2011 09:50:08 -0700
Message-ID: <BANLkTikPk19z6qfVoU_TQ72YMVZeRn7E+g@mail.gmail.com>
References: <1304559247-16111-1-git-send-email-maheshb@google.com>
	<1304749117-1989-1-git-send-email-maheshb@google.com>
	<20110507074321.GB4522@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:37035 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab1EHQuM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 12:50:12 -0400
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p48GoBAg021373
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 09:50:11 -0700
Received: from bwz12 (bwz12.prod.google.com [10.188.26.12])
	by hpaq11.eem.corp.google.com with ESMTP id p48Go93M026069
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 09:50:10 -0700
Received: by bwz12 with SMTP id 12so7509782bwz.27
        for <netdev@vger.kernel.org>; Sun, 08 May 2011 09:50:09 -0700 (PDT)
In-Reply-To: <20110507074321.GB4522@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 7, 2011 at 12:43 AM, Micha=C5=82 Miros=C5=82aw
<mirq-linux@rere.qmqm.pl> wrote:
> On Fri, May 06, 2011 at 11:18:37PM -0700, Mahesh Bandewar wrote:
>> This patch adds tg3_set_features() to handle loopback mode. Currentl=
y the
>> capability is added for the devices which support internal MAC loopb=
ack mode.
>> So when enabled, it enables internal-MAC loopback.
> [...]
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index 7c7c9a8..b7270c2 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
> [...]
>> @@ -6319,6 +6356,24 @@ static u32 tg3_fix_features(struct net_device=
 *dev, u32 features)
>> =C2=A0 =C2=A0 =C2=A0 return features;
>> =C2=A0}
>>
>> +static int tg3_set_features(struct net_device *dev, u32 features)
>> +{
>> + =C2=A0 =C2=A0 struct tg3 *tp =3D netdev_priv(dev);
>> + =C2=A0 =C2=A0 u32 changed =3D dev->features ^ features;
>> +
>> + =C2=A0 =C2=A0 if (changed & NETIF_F_LOOPBACK) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (tg3_flag(tp, LOOPBAC=
K_ENABLED))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 tg3_flag_clear(tp, LOOPBACK_ENABLED);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 tg3_flag_set(tp, LOOPBACK_ENABLED);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (netif_running(dev))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 tg3_set_loopback(dev);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> =C2=A0static inline void tg3_set_mtu(struct net_device *dev, struct =
tg3 *tp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int new_mtu)
>> =C2=A0{
>> @@ -9485,6 +9540,13 @@ static int tg3_open(struct net_device *dev)
>>
>> =C2=A0 =C2=A0 =C2=A0 netif_tx_start_all_queues(dev);
>>
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* Reset loopback feature if it was turned on w=
hile the device was down
>> + =C2=A0 =C2=A0 =C2=A0* make sure that it's installed properly now.
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 if (tg3_flag(tp, LOOPBACK_ENABLED))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tg3_set_loopback(dev);
>> +
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>>
>> =C2=A0err_out3:
> [...]
>
> So, you've just implemented what I said about enabling loopback at th=
e end
> of tg3_open(), but you also added (redundant) flag that mirrors
> dev->features & NETIF_F_LOOPBACK. Why?
>
I had tried it before but it failed and I thought the device is not
ready at the end of ndo_open call back, but in fact my change itself
was causing the discrepancy in driver's private data structure. This I
found while debugging the change and corrected by using tp->mac_mode
for the current state of that reg instead of reading it from the reg
into a local variable. I agree, as a side effect of this a redundant
flag got created, which I'll remove. Thanks for pointing it out.

Regards,
--mahesh..

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
