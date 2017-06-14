From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 01/11] ipv6: skb_put_zero() used to optimize
 code
Date: Wed, 14 Jun 2017 12:14:16 -0700
Message-ID: <20170614121416.63a78b0d@xeon-e3>
References: <1497451026-3923-1-git-send-email-cugyly@163.com>
        <20170614084434.3342671d@xeon-e3>
        <1497466892.9377.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35792 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdFNTOX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:14:23 -0400
Received: by mail-pg0-f54.google.com with SMTP id k71so4224779pgd.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 12:14:23 -0700 (PDT)
In-Reply-To: <1497466892.9377.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 21:01:32 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Wed, 2017-06-14 at 08:44 -0700, Stephen Hemminger wrote:
> >  =20
> > > =C2=A0	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
> > > =C2=A0
> > > -	hdr =3D (struct mld_msg *) skb_put(skb, sizeof(struct
> > > mld_msg));
> > > -	memset(hdr, 0, sizeof(struct mld_msg));
> > > +	hdr =3D (struct mld_msg *) skb_put_zero(skb, sizeof(struct
> > > mld_msg)); =20
> >=20
> > Why does skb_put_zero return char * instead of void *?
> > If returned void * it would save having to add lots of casts.
> >=20
> > One could even go farther by making skb_put_zero a macro and
> > use typeof(). =20
>=20
> I just copied it from skb_put() - you could ask the same there? :)

My taste is to  have less casts. Never understood why so many skb_
functions returned char *, probably a leftover from older Unix style.
