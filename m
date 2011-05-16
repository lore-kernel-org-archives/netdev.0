From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 12:53:51 +0200
Message-ID: <BANLkTikvY+8FTO+V9bM1cNwhuOvr7LPptw@mail.gmail.com>
References: <20110504181813.GA17547@redhat.com> <20110504223415.GA14819@gondor.apana.org.au>
 <20110504232854.GA11687@rere.qmqm.pl> <20110505084428.GB17647@redhat.com>
 <4DC26F33.8010700@cn.fujitsu.com> <20110505100506.GA20111@gondor.apana.org.au>
 <20110516073210.GB6610@redhat.com> <20110516080702.GA1857@gondor.apana.org.au>
 <20110516081841.GA8073@redhat.com> <20110516093822.GA2779@gondor.apana.org.au>
 <20110516094821.GA9427@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48940 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab1EPKyM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 06:54:12 -0400
Received: by qwk3 with SMTP id 3so2184786qwk.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 03:54:11 -0700 (PDT)
In-Reply-To: <20110516094821.GA9427@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/16 Michael S. Tsirkin <mst@redhat.com>:
> On Mon, May 16, 2011 at 07:38:22PM +1000, Herbert Xu wrote:
>> On Mon, May 16, 2011 at 11:18:41AM +0300, Michael S. Tsirkin wrote:
>> >
>> > There's no interface for userspace to enable it: userspace
>> > only has an ioctl to enable/disable checksum offloading.
>> > SG is an implementation detail.
>> Yes there is: ethtool -K
> Ok. You are right of course, I was confused.
>
> So it's just an info message: in the end if userspace DTRT features
> get enabled properly. Functionally, there is no regression.

I proposed changing those messages to DEBUG level some time ago.Those
dependencies are constant, so they could be moved to
Documentation/networking/.

> Both bridge and tun trigger the messages ATM. I note that
> dev.c takes pains to avoid these messages:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Avoid warning from netdev_fix_features() f=
or GSO without SG
>
> Should all drivers do this: clear _SG if they clear checksum? =C2=A0W=
hat about _GSO?
> If we start doing this, this spills info about flag dependencies out =
to drivers.

Drivers should not care about those dependencies.

Best Regards,
Micha=C5=82 Miros=C5=82aw
