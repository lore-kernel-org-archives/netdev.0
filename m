From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 17:16:03 +0100
Message-ID: <1324656963.4540.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
	 <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324654013.10184.597.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40394 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557Ab1LWQQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 11:16:07 -0500
Received: by wgbdr13 with SMTP id dr13so17672777wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 08:16:05 -0800 (PST)
In-Reply-To: <1324654013.10184.597.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 10:26 -0500, John A. Sullivan =
III a
=C3=A9crit :

> Yes.  This is a problem I have with netem on ingress traffic.  I use =
the
> filter on ffff: to redirect to ifb0 for the ingress traffic shaping. =
 I
> cannot figure out a way to redirect a second time to ifb1 for the net=
em
> qdisc.  I tried putting two action mirred statements in the filter bu=
t
> that did not work.  Unlike eth1, I cannot attach a filter further dow=
n
> the ifb0 hfsc hierarchy because one can't redirect one ifb into anoth=
er
> ifb.  Thus, the only way I could figure out how to do inbound netem w=
as
> to replace the terminal qdisc with netem rather than SFQ.  I'd love t=
o
> be able to do that differently.  I tried attaching netem to the SFQ b=
ut
> that failed (I assume because SFQ is classless) and I tried the other
> way around, attaching SFQ to netem since you mentioned netem could ta=
ke
> a class but that did not work either.

Unfortunately, netem wants to control skbs itself, in a fifo queue.

To implement what you want, we would need to setup a second qdisc,
and when packets are dequeued from internal netem fifo, queue them in
second qdisc.
