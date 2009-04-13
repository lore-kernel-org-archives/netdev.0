From: David Miller <davem@davemloft.net>
Subject: Re: initial congestion window for connections in the listen queue
Date: Mon, 13 Apr 2009 14:58:29 -0700 (PDT)
Message-ID: <20090413.145829.97306950.davem@davemloft.net>
References: <200904132346.15783.opurdila@ixiacom.com>
	<20090413.142653.267913010.davem@davemloft.net>
	<Pine.LNX.4.64.0904140051100.9234@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751540AbZDMV6l convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 17:58:41 -0400
In-Reply-To: <Pine.LNX.4.64.0904140051100.9234@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 14 Apr 2009 00:54:40 +0300 (EEST)

> A long-standing feature in tcp_init_metrics() is such that any of its=
 goto=20
> reset prevents call to tcp_init_cwnd(). I never remembered to fix tha=
t.

Grumble, we definitely need to fix that!

I suspect I added that problem, because tcp_init_metrics() at one
point couldn't cope with a NULL dst.  But that is no longer the
case so I'm pretty sure we can unconditionally go:

	tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
	tp->snd_cwnd_stamp =3D tcp_time_stamp;

in the 'reset' path too, right?

But note thata even if this reset path is taken, we should still have
at least the default ->snd_cwnd value of 2.
