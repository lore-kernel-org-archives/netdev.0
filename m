From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 18:33:59 +0100
Message-ID: <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45924 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757524Ab1LWReE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 12:34:04 -0500
Received: by werm1 with SMTP id m1so4090431wer.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 09:34:03 -0800 (PST)
In-Reply-To: <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 d=C3=A9cembre 2011 =C3=A0 11:55 -0800, Stephen Hemminger=
 a =C3=A9crit :
> On Sun, 18 Dec 2011 00:12:12 -0500
> "John A. Sullivan III" <jsullivan@opensourcedevel.com> wrote:
>=20
> > Since netem appears to be classless, we realized we would need to
> > replace the SFQ on each leaf with netem which we really didn't want=
 to
> > do - not only to not lose SFQ but because we didn't want to maintai=
n the
> > netem parameters on each leaf.  So, we activated our ifb1 interface=
,
> > placed netem on it and redirected all the egress traffic to ifb1.  =
Taht
> > worked fine.
>=20
> Current versions of netem can take one class.
> --

Hmm, I can see that (commit 10f6dfcfde884441)=20

But it wont work very well, it assumes qdisc uses a single queue if
netem reordering is requested :

(__skb_queue_head(&q->qdisc->q, skb))

We should allow reordering if netem queue is changed from tfifo, only i=
f
new qdisc is compatible with __skb_queue_head(&q->qdisc->q, skb)

(maybe providing a new ->queue_at_head() new ops)
