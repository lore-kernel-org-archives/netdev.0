From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: send IPIs ASAP
Date: Tue, 20 Apr 2010 07:45:51 +0200
Message-ID: <1271742351.3845.106.camel@edumazet-laptop>
References: <1271736519-2991-1-git-send-email-xiaosuo@gmail.com>
	 <g2y65634d661004192215oc06d9c43xb2a7c7d946149cf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:37688 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913Ab0DTFp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 01:45:57 -0400
Received: by bwz19 with SMTP id 19so134945bwz.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 22:45:56 -0700 (PDT)
In-Reply-To: <g2y65634d661004192215oc06d9c43xb2a7c7d946149cf5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 22:15 -0700, Tom Herbert a =C3=A9crit :
> On Mon, Apr 19, 2010 at 9:08 PM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
> > rps: send IPIs ASAP
> >
> > In order to reduce latency, we'd better send IPIs ASAP to schedule =
the
> > corresponding NAPIs.
> >
> A design point of RPS is that we generate at most one IPI per CPU per
> device interrupt, which at least offers some predictable coalescing.
> With your changes, we would get at most one IPI per packet-- that
> could represent a lot more of them.  Did you test this to see what th=
e
> impact is in this regard?
>=20

I agree with you Tom. Coalescing IPI is probably better.

If the receiver CPU got a single packet in its RX handling, latency wil=
l
be the same anyway.

If the receiver CPU got many packets, chance is high we are in a stress
situation, and coalescing is a win in this case.

I am currently testing a patch to call net_rps_action() at the beginnin=
g
of process_backlog() (if we have a non null ipi_rps_list pointer)

Will post a patch with bench results



