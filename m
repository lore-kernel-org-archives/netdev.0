From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Tue, 03 Jun 2008 16:35:18 -0700 (PDT)
Message-ID: <20080603.163518.153888925.davem@davemloft.net>
References: <Pine.LNX.4.64.0805241156120.27780@wrl-59.cs.helsinki.fi>
	<cf4145200805240706p2eb54e9ei51bc33f782ff5aef@mail.gmail.com>
	<Pine.LNX.4.64.0805261349510.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.vowell@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753905AbYFCXfT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 19:35:19 -0400
In-Reply-To: <Pine.LNX.4.64.0805261349510.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 26 May 2008 14:24:33 +0300 (EEST)

Ilpo, do you want me to apply this to net-2.6?

> [PATCH] [TCP]: Fix inconsistency source (CA_Open only when !tcp_left_=
out(tp))
>=20
> It is possible that this skip path causes TCP to end up into an
> invalid state where ca_state was left to CA_Open while some
> segments already came into sacked_out. If next valid ACK doesn't
> contain new SACK information TCP fails to enter into
> tcp_fastretrans_alert(). Thus at least high_seq is set
> incorrectly to a too high seqno because some new data segments
> could be sent in between (and also, limited transmit is not
> being correctly invoked there). Reordering in both directions
> can easily cause this situation to occur.
>=20
> I guess we would want to use tcp_moderate_cwnd(tp) there as well
> as it may be possible to use this to trigger oversized burst to
> network by sending an old ACK with huge amount of SACK info, but
> I'm a bit unsure about its effects (mainly to FlightSize), so to
> be on the safe side I just currently fixed it minimally to keep
> TCP's state consistent (obviously, such nasty ACKs have been
> possible this far). Though it seems that FlightSize is already
> underestimated by some amount, so probably on the long term we
> might want to trigger recovery there too, if appropriate, to make
> FlightSize calculation to resemble reality at the time when the
> losses where discovered (but such change scares me too much now
> and requires some more thinking anyway how to do that as it
> likely involves some code shuffling).
>=20
> This bug was found by Brian Vowell while running my TCP debug
> patch to find cause of another TCP issue (fackets_out
> miscount).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
