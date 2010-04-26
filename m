From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 10:38:27 -0700
Message-ID: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
	 <1272302434.19143.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4330 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab0DZRia convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 13:38:30 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o3QHcTUV023530
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 10:38:29 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by kpbe18.cbf.corp.google.com with ESMTP id o3QHbROt006957
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 10:38:28 -0700
Received: by pwi1 with SMTP id 1so8159879pwi.11
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 10:38:28 -0700 (PDT)
In-Reply-To: <1272302434.19143.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Tom
>
> I tested this rxhash feature on my bnx2x card, using latest net-next-=
2.6
> and appropriate ethtool
>
> ethtool -k eth1 rxhash on
>
> Then I used my pktgen script, to flood machine with flows with udp ds=
t
> port varying between 4000 and 4015.
>
> Software generated rxhash is OK (16 different values).
>
> But with bnx2x provided hash, all skb were hashed to same rxhash
> value :(
>
> What are the specs of this hardware hash ?
> It seems to not care of udp source/destination ports.
>

It would appear that way :-(.  I was going to ping Broadcom folks to
see if there's support for UDP.

> Also, should'nt we feed same values for the seeds on different nics ?
>
> for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D 4)
> =A0 =A0 =A0 =A0REG_WR(bp, i, random32());
>

Yes, that is reasonable.

> Thanks
>
>
>
