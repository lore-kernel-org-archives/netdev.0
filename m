From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: avoid lockup when TGO during underrun
Date: Sun, 18 Jan 2009 21:57:49 -0800 (PST)
Message-ID: <20090118.215749.215909519.davem@davemloft.net>
References: <496F80B8.6020408@endian.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@endian.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755774AbZASF5s convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 00:57:48 -0500
In-Reply-To: <496F80B8.6020408@endian.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@endian.se>
Date: Thu, 15 Jan 2009 19:30:16 +0100

> This patch against linux-2.6.28 solves an issue where macb might run =
out of TX buffers.
>=20
> In rare cases when an underrun occur, all macb buffers where consumed=
 and the netif_queue was stopped infinitely. This
> happens then the TGO (transfer ongoing) bit in the TSR is set (and UN=
D). It seems like clening up after the underrun
> makes the driver and the macb hardware end up in an inconsistent stat=
e. The result of this is that in the following
> calls to macb_tx no TX buffers are released -> the netif_queue was st=
opped, and never woken up again.
>=20
> The solution is to disable the transmitter, if TGO is set, before cle=
ning up after the underrun, and re-enable the
> transmitter when the cleaning up is done.
>=20
>=20
> A patch to avoid lockup in the macb driver in some rare underrun case=
s.
> Signed-off-by: Richard R=F6jfors <richard.rojfors@endian.se>

Patch applied, thanks Richard.
