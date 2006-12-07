From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] convert hh_lock to seqlock
Date: Thu, 7 Dec 2006 13:15:53 -0800
Message-ID: <20061207131553.45e4388b@localhost>
References: <20061207113309.2f892cf1@localhost>
	<4578782B.4010908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:40332 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163378AbWLGVQJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 16:16:09 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4578782B.4010908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 07 Dec 2006 21:23:07 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > The hard header cache is in the main output path, so using
> > seqlock instead of reader/writer lock should reduce overhead.
> >=20
>=20
> Nice work Stephen, I am very interested.
>=20
> Did you benchmarked it ?
>=20
> I ask because I think hh_refcnt frequent changes may defeat the gain =
you want=20
> (ie avoiding cache line ping pongs between cpus). seqlock are definit=
ly better=20
> than rwlock, but if we really keep cache lines shared.
>=20
> So I would suggest reordering fields of hh_cache and adding one=20
> ____cacheline_aligned_in_smp to keep hh_refcnt in another cache line.
>=20
> (hh_len, hh_lock and hh_data should be placed on a 'mostly read' cach=
e line)
>=20
> Thank you
> Eric

It doesn't make any visible performance difference for real networks;=20
copies and device issues are much larger.

The hh_refcnt is used only when creating destroying neighbor entries,
so except under DoS attack it doesn't make a lot of difference.
The hh_lock is used on each packet sent.
