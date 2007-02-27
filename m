From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP]: Add two new spurious RTO responses to FRTO
Date: Tue, 27 Feb 2007 10:10:26 -0800 (PST)
Message-ID: <20070227.101026.89037327.davem@davemloft.net>
References: <Pine.LNX.4.64.0702271738340.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59738
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751942AbXB0SK2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 13:10:28 -0500
In-Reply-To: <Pine.LNX.4.64.0702271738340.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 27 Feb 2007 17:50:06 +0200 (EET)

> New sysctl tcp_frto_response is added to select amongst these
> responses:
> 	- Rate halving based; reuses CA_CWR state (default)
> 	- Very conservative; used to be the only one available (=3D1)
> 	- Undo cwr; undoes ssthresh and cwnd reductions (=3D2)
>=20
> The response with rate halving requires a new parameter to
> tcp_enter_cwr because FRTO has already reduced ssthresh and
> doing a second reduction there has to be prevented. In addition,
> to keep things nice on 80 cols screen, a local variable was
> added.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to tcp-2.6, thanks!

I tidied up the coding style of the switch statement slightly.
So that it reads like this:

		switch (sysctl_tcp_frto_response) {
		case 2:
			tcp_undo_spur_to_response(sk);
			break;
		case 1:
			tcp_conservative_spur_to_response(tp);
			break;
		default:
			tcp_ratehalving_spur_to_response(sk);
			break;
		};

Thanks again.
