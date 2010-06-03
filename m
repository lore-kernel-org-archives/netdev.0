From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Thu, 3 Jun 2010 11:21:16 +0800
Message-ID: <AANLkTim3WVTyMf2RvKRvyJn90sAyw1-ZShTfvvMlQolJ@mail.gmail.com>
References: <1275383974.1010.5.camel@eight.analog.com>
	<20100602.070233.37574714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60593 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933730Ab0FCDVS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 23:21:18 -0400
Received: by pwj2 with SMTP id 2so2018444pwj.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 20:21:17 -0700 (PDT)
In-Reply-To: <20100602.070233.37574714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 2, 2010 at 10:02 PM, David Miller <davem@davemloft.net> wro=
te:
> From: sonic zhang <sonic.adi@gmail.com>
> Date: Tue, 1 Jun 2010 17:19:34 +0800
>
>> @@ -1485,6 +1506,10 @@ static int __devinit bfin_mac_probe(struct pl=
atform_device *pdev)
>> =A0 =A0 =A0 ndev->netdev_ops =3D &bfin_mac_netdev_ops;
>> =A0 =A0 =A0 ndev->ethtool_ops =3D &bfin_mac_ethtool_ops;
>>
>> + =A0 =A0 init_timer(&lp->tx_reclaim_timer);
>> + =A0 =A0 lp->tx_reclaim_timer.data =3D (unsigned long)(lp);
>

OK

> Putting parenthesis around "lp" is excessive, please don't do this.
>
>> + =A0 =A0 lp->tx_reclaim_timer.function =3D (void *)tx_reclaim_skb;
>> +
>> =A0 =A0 =A0 spin_lock_init(&lp->lock);
>
> Do not cast the function pointer to "void *" like this, it's ugly and=
 entirely
> not necessary.
>
> Instead have a wrapper function that uses the correct types as specif=
ied
> for timer functions, that calls the existing function.
>

No problem.

Sonic
