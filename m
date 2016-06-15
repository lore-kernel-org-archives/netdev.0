From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next v2] tcp: use RFC6298 compliant TCP RTO
 calculation
Date: Wed, 15 Jun 2016 19:41:14 +0200
Message-ID: <20160615174114.GA16217@virgo.localdomain>
References: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
 <20160614191841.21496-1-dmetz@mytum.de>
 <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Metz <dmetz@mytum.de>, netdev <netdev@vger.kernel.org>,
	Daniel Metz <daniel.metz@rohde-schwarz.com>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:34368 "EHLO mx2.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbcFORlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 13:41:31 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Yuchung Cheng | 2016-06-14 14:33:18 [-0700]:

>> +               tp->rttvar_us =3D tp->mdev_us;
>AFAICT we can update rttvar_us directly and don't need mdev_us anymore=
?

Yes, v3 will remove mdev_us.

>This is more aggressive than  RFC6298 that RTO <- SRTT + max (G,
>K*RTTVAR) where G =3D MIN_RTO =3D 200ms
>
>based on our discussion, in the spirit of keeping RTO more
>conservative, I recommend we implement RFC formula. Acks being delayed
>over 200ms is not uncommon (unfortunately due to bloat or other
>issues).
>
>Also I think we should change __tcp_set_rto so that the formula
>applies to backoffs or ICMP timeouts calculations too.

We are a unsure what you mean Yuchung. We believe this patch not to be =
more
aggressive than RFC 6298. In fact, we believe it to be RFC 6298 complia=
nt, as
in RFC 6298, G is the clock granularity and we don=E2=80=99t see where =
it deviates
from the RFC. However, it is more aggressive than =E2=80=9CRTO <- SRTT =
+ max (G,
K*RTTVAR) where G =3D MIN_RTO =3D 200ms=E2=80=9D. Which formula do you =
want to implement?

Hagen
