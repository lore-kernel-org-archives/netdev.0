From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] ethtool: __ethtool_set_sg: check for function pointer
 before using it
Date: Thu, 17 Mar 2011 18:00:42 +0100
Message-ID: <AANLkTinTWDLhqURAtEanOsry=2x8QSQKZca7B7Au5mrn@mail.gmail.com>
References: <20110317163720.GA26284@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:42540 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab1CQRBD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 13:01:03 -0400
Received: by qyk7 with SMTP id 7so93754qyk.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 10:01:02 -0700 (PDT)
In-Reply-To: <20110317163720.GA26284@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/17 Roger Luethi <rl@hellgate.ch>:
> __ethtool_set_sg does not check if dev->ethtool_ops->set_sg is define=
d
> which can result in a NULL pointer dereference when ethtool is used t=
o
> change SG settings for drivers without SG support.
>
> Signed-off-by: Roger Luethi <rl@hellgate.ch>
> ---
>
> Bug verified. Patch only compile-tested.
>
> =C2=A0net/core/ethtool.c | =C2=A0 =C2=A03 +++
> =C2=A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..a1086fb 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1457,6 +1457,9 @@ static int __ethtool_set_sg(struct net_device *=
dev, u32 data)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>
> + =C2=A0 =C2=A0 =C2=A0 if (!dev->ethtool_ops->set_sg)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EOPNOTSUPP=
;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (data && !(dev->features & NETIF_F_ALL_=
CSUM))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL=
;
>

Yes. __ethtool_set_sg() is the only function that was already there
before my unification series and I did tests only on drivers which had
set_sg() defined. :-/

This should go into 2.6.39 as a bugfix (adding Cc: DaveM).

Best Regards,
Micha=C5=82 Miros=C5=82aw
