From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] [TCP]: Remove unnecessary local variables
Date: Mon, 31 Dec 2007 04:47:59 -0800 (PST)
Message-ID: <20071231.044759.141743569.davem@davemloft.net>
References: <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757962AbXLaMsA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 07:48:00 -0500
In-Reply-To: <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 31 Dec 2007 12:47:51 +0200

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
 ...
> =20
> -	in_flight =3D tcp_packets_in_flight(tp);
> -	cwnd =3D tp->snd_cwnd;
> -	if (in_flight < cwnd)
> -		return (cwnd - in_flight);
> +	if (tcp_packets_in_flight(tp) < tp->snd_cwnd)
> +		return tp->snd_cwnd - tcp_packets_in_flight(tp);
> =20

I don't know about this one.

Although tcp_packets_in_flight() is inline and the compiler
should CSE the first call into a local register and not
redo the calculation:

1) That isn't something to rely upon.  The compiler might look
   at a function or set of functions in this file and decide
   to not inline tcp_packets_in_flight() or not see the CSE
   opportunity and that the second call is redundant.

2) If we stop inlining tcp_packets_in_flight() then nobody, and I
   mean nobody, is going to remember to come back here and
   add back the code to put the result in a local variable.

So best to keep the local vars here.

I also think the code is clearer that way too.

Thanks.
