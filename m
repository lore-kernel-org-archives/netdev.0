From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] rfs: Receive Flow Steering
Date: Fri, 9 Apr 2010 06:50:44 -0700
Message-ID: <l2q65634d661004090650z12b8c192u866c812477fddf11@mail.gmail.com>
References: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
	 <1270797457.2623.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:4136 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab0DINuv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 09:50:51 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o39Domcm026665
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 15:50:49 +0200
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by wpaz9.hot.corp.google.com with ESMTP id o39Doc9x030837
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 06:50:46 -0700
Received: by pwi8 with SMTP id 8so2862510pwi.29
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 06:50:46 -0700 (PDT)
In-Reply-To: <1270797457.2623.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> =A0 * @mc_ttl - Multicasting TTL
>> =A0 * @is_icsk - is this an inet_connection_sock?
>> @@ -124,6 +126,9 @@ struct inet_sock {
>> =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmsg_flags;
>> =A0 =A0 =A0 __be16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_sport;
>> =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_id;
>> +#ifdef CONFIG_RPS
>> + =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxhash;
>> +#endif
>
> I am a bit worried, because dirtying this cache line might hurt non R=
PS
> setups (if network interrupts are balanced to all cpus)
>
The rxhash should only be written when it changes.  So as long as
device or lower stack provide a consistent rxhash for a connection
this should be okay.

> Best place would be to put rxhash close to sk_refcnt (because we dirt=
y
> it to get a reference on rcu sk lookups)
>
In sock_common?... I don't know if we need this in every socket yet.

> I believe we have a 32bits hole on 64bit arches for this :)
>
>
> While testint latest net-nex-2.6 on my nehalem machine, I got a crash
> (in RPS I am afraid...)
>
> I am going to correct this crash before testing RFS and let you know =
the
> results.

Thanks for doing that.

>
> Thanks
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
