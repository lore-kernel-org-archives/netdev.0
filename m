From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] convert hh_lock to seqlock
Date: Thu, 7 Dec 2006 14:53:00 -0800
Message-ID: <20061207145300.3a5a21a6@localhost>
References: <20061207113309.2f892cf1@localhost>
	<4578782B.4010908@cosmosbay.com>
	<20061207131553.45e4388b@localhost>
	<45789534.1050703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:49899 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163556AbWLGWxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 17:53:30 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <45789534.1050703@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 07 Dec 2006 23:27:00 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Thu, 07 Dec 2006 21:23:07 +0100
> > Eric Dumazet <dada1@cosmosbay.com> wrote:
> >=20
> >> Stephen Hemminger a =C3=A9crit :
> >>> The hard header cache is in the main output path, so using
> >>> seqlock instead of reader/writer lock should reduce overhead.
> >>>
> >> Nice work Stephen, I am very interested.
> >>
> >> Did you benchmarked it ?
> >>
> >> I ask because I think hh_refcnt frequent changes may defeat the ga=
in you want=20
> >> (ie avoiding cache line ping pongs between cpus). seqlock are defi=
nitly better=20
> >> than rwlock, but if we really keep cache lines shared.
> >>
> >> So I would suggest reordering fields of hh_cache and adding one=20
> >> ____cacheline_aligned_in_smp to keep hh_refcnt in another cache li=
ne.
> >>
> >> (hh_len, hh_lock and hh_data should be placed on a 'mostly read' c=
ache line)
> >>
> >> Thank you
> >> Eric
> >=20
> > It doesn't make any visible performance difference for real network=
s;=20
> > copies and device issues are much larger.
>=20
> Hum, so 'my' machines must be unreal :)
>=20
> >=20
> > The hh_refcnt is used only when creating destroying neighbor entrie=
s,
> > so except under DoS attack it doesn't make a lot of difference.
> > The hh_lock is used on each packet sent.
>=20
> Some machines create/delete 10.000 entries per second in rt_cache.
> I believe they are real. DoS ? you tell it, some people wont agree.


That could be fixed by doing RCU, I did some of that previously, but it
seemed better to hit the worst case first.  Even Robert doesn't see 10,=
000
rt cache entries per second.
