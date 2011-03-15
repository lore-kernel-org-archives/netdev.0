From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Tue, 15 Mar 2011 11:20:54 +0100
Message-ID: <201103151120.55388.carsten@wolffcarsten.de>
References: <1299894051-13820-1-git-send-email-ycheng@google.com> <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com> <AANLkTi=qi2GOprXEWCf6v=j=L98SQMdHb1OaHcdALepf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:36476 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab1COKVM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:21:12 -0400
In-Reply-To: <AANLkTi=qi2GOprXEWCf6v=j=L98SQMdHb1OaHcdALepf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 March 2011, John Heffner wrote:
> On Mon, Mar 14, 2011 at 3:10 PM, Yuchung Cheng <ycheng@google.com> wr=
ote:
> > On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff <carsten@wolffcarste=
n.de>=20
wrote:
> >> The moderation is in place to avoid gigantic segment bursts, which=
 could
> >> cause unnecessary pressure on buffers. In my eyes it's already
> >> suboptimal that the moderation is weakened in the presence of
> >> (detected) reordering, let alone removing it completely.
> >=20
> > In the presence of reordering, cwnd is already moderated in Disorde=
r
> > state before
> >  entering the (false) recovery.
>=20
> I've always been somewhat skeptical of the usefulness of cwnd
> moderation.  First, I don't know that its behavior is well defined.
> When *should* tcp_moderate_cwnd() actually be called, and why?
>=20
> Second, I've never liked the idea in general.  Reducing cwnd has an
> effect lasting many RTTs, so reducing it in response to a transient
> event like reordering seems dubious.  And it does not address many
> causes of bursts, such as ack compression or stretch acks.

I think the undo operations are a special case where it absolutely make=
s=20
sense, because the cwnd _already_ has been reduced (down to 1 segment b=
y RTO=20
recovery, or, with its special mixture of ratehalving and newreno, Linu=
x=20
sometimes reduces cwnd far below half of it even in fast recovery.). Th=
e undo=20
re-opens the window all at once, which may allow _really huge_ bursts. =
I don't=20
know enough about the other causes of TCPs burstiness, I'm just concern=
ed=20
about allowing this special cause.

Carsten
--=20
           /\-=C2=B4-/\
          (  @ @  )
________o0O___^___O0o________
