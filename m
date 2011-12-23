From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 18:39:10 +0100
Message-ID: <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39453 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110Ab1LWRjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 12:39:14 -0500
Received: by wgbdr13 with SMTP id dr13so17766973wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 09:39:13 -0800 (PST)
In-Reply-To: <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 18:33 +0100, Eric Dumazet a =C3=
=A9crit :
> Le dimanche 18 d=C3=A9cembre 2011 =C3=A0 11:55 -0800, Stephen Hemming=
er a =C3=A9crit :
> > On Sun, 18 Dec 2011 00:12:12 -0500
> > "John A. Sullivan III" <jsullivan@opensourcedevel.com> wrote:
> >=20
> > > Since netem appears to be classless, we realized we would need to
> > > replace the SFQ on each leaf with netem which we really didn't wa=
nt to
> > > do - not only to not lose SFQ but because we didn't want to maint=
ain the
> > > netem parameters on each leaf.  So, we activated our ifb1 interfa=
ce,
> > > placed netem on it and redirected all the egress traffic to ifb1.=
  Taht
> > > worked fine.
> >=20
> > Current versions of netem can take one class.
> > --
>=20
> Hmm, I can see that (commit 10f6dfcfde884441)=20
>=20
> But it wont work very well, it assumes qdisc uses a single queue if
> netem reordering is requested :
>=20
> (__skb_queue_head(&q->qdisc->q, skb))
>=20
> We should allow reordering if netem queue is changed from tfifo, only=
 if
> new qdisc is compatible with __skb_queue_head(&q->qdisc->q, skb)
>=20
> (maybe providing a new ->queue_at_head() new ops)

Also, child qdisc must not scratch skb->cb[], since netem stores
time_to_send in it.

I guess nobody actually tried this netem mis-feature :(

I'll send a fix.
