From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Tue, 31 Aug 2010 23:47:20 +0200
Message-ID: <20100831214720.GB3093@del.dom.local>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com>
 <20100831210101.3c059a91@leibniz>
 <4C7D5EBD.103@gmail.com>
 <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@osdl.org>
To: Dan Kruchinin <dkruchinin@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39406 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755382Ab0HaVr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 17:47:27 -0400
Received: by fxm13 with SMTP id 13so4310951fxm.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 14:47:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 01:00:53AM +0400, Dan Kruchinin wrote:
> On Tue, Aug 31, 2010 at 11:57 PM, Jarek Poplawski <jarkao2@gmail.com>=
 wrote:
> > Dan Kruchinin wrote, On 08/31/2010 07:01 PM:
> >
> >> I'm sorry it seems my email client has broken patch formating.
> >> Here is properly formated one:
> >> diff --git a/tc/q_tbf.c b/tc/q_tbf.c
> >> index dc556fe..850e6db 100644
> >> --- a/tc/q_tbf.c
> >> +++ b/tc/q_tbf.c
> >> @@ -178,7 +178,7 @@ static int tbf_parse_opt(struct qdisc_util *qu=
, int argc, char **argv, struct nl
> >> =A0 =A0 =A0 }
> >>
> >> =A0 =A0 =A0 if (opt.limit =3D=3D 0) {
> >> - =A0 =A0 =A0 =A0 =A0 =A0 double lim =3D opt.rate.rate*(double)lat=
ency/TIME_UNITS_PER_SEC + buffer;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 double lim =3D opt.rate.rate*(double)lat=
ency/TIME_UNITS_PER_SEC;
> >
> > The way limit is calculated here from latency suggests some safety =
defaults
> > are taken wrt. the implementation, which could be omitted while set=
ting the
> > limit directly. You try to change/fix this to adhere to the documen=
tation,
> > but such a change would definitely break many user configs, so I do=
ubt it's
> > the right solution here. Probably you should rather think about fix=
ing the
> > manual.
>=20
> Thank you for comments.
> The only thing that embarrasses me abut documentation fixing is that
> the latency loses all its sense.

Hmm... As a matter of fact, I'm not too picky about docs (and happy if
they don't skip some params at all), but your test with such a high
burst wrt. the rate didn't make much sense to me either. ;-)

> Documentation describes latency as something intuitively clear: "the
> maximum amount of time a packet can sit in the TBF"
> but tc implementation handles it something like: "an additional time
> packet can sit int the TBF after main waiting queue which size is
> equal to the burst size is completely full.". It doesn't seem to have
> any sense.
> Moreover, user can pass "limit" value to tc directly and if this limi=
t
> value is less than burst size then latency will be improperly
> calculated(it'll have a negative value) which is not good as well.

Yes, many params could be misused/abused in tc without a warning, so
people have to test their configs first, and often learn this way how
it really works. So the docs are often secondary, which is not right
of course.

> By the way, the following descriptions of TBF algorithm are proposed
> the same the manual says:
> http://www.opalsoft.net/qos/DS-24.htm
> ww.docum.org/docum.org/docs/other/tbf02_kw.ps
>=20
> If the documentation should be fixed I'm not sure that latency can be
> somehow logically described to have any sense at all.

I guess there could be added a warning there is such a difference.

Jarek P.
