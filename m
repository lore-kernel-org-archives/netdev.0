From: "Leslie Rhorer" <lrhorer@satx.rr.com>
Subject: RE: can TCP send buffer be over used?
Date: Thu, 5 Aug 2010 02:20:37 -0500
Message-ID: <CE.C0.27492.8466A5C4@cdptpa-omtalb.mail.rr.com>
References: <AANLkTikWH8NQZ5CYN7ytPYg-tK=eXF=OgJn=cuAoVexO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "'Jack Zhang'" <jack.zhang2011@gmail.com>,
	<linux-net@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:50355 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758847Ab0HEHUl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 03:20:41 -0400
In-Reply-To: <AANLkTikWH8NQZ5CYN7ytPYg-tK=eXF=OgJn=cuAoVexO@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is one part of your suggestion I'm not sure if I fully
> understand though...  "the transmitter cannot be allowed to send more
> data without acknowledgement of receipt of all the sent data than the
> receiver can assemble in one chunk. " I take it as the transmitter
> cannot send data of more than the receive window size without ack of
> the sent data. Is that what you meant?

	For TCP, yes.  In general it is true of any protocol which
guarantees intact delivery of data.  The far (Rx) end must be able to
assemble all the data in good order if no data is to be lost.  If the f=
ar
end can only buffer N blocks of data and the transmitter sends N + 1 bl=
ocks
of data before the far end can properly assemble the chunk, then the fa=
r end
has to discard one of the blocks of data.

	TCP employs a sliding window, so once N blocks of data have been
assembled by the Rx system, it sends and ACK for the Nth block back to =
the
Tx host, whereupon the Tx host moves up its pointer for the window's
starting position to N + 1, and continues transmitting until the end of=
 the
window is reached.  If the latency is very small and the link error fre=
e, it
may never reach the end of the window, and the transfer will proceed at=
 wire
speed.  Otherwise, the near host transmits until it reaches the end of =
the
buffer whose size has been negotiated between the near and far system, =
and
then waits for an acknowledgement from the far end.  When it comes, it =
may
not be an acknowledgement for the 1st block of data in the window, but
rather for some number of blocks, or perhaps even the entire window.
However many blocks are acknowledged, the Tx system moves its window po=
inter
up by that many blocks, and transmission begins again.

> > 3. =A0Your measurement is based upon transfers that are too small i=
n
> extent.
>=20
> I was transferring 1 GB data over the 100 Mbps link. Do you think if =
I
> should increase the size of the transfer?

	No.  As long as the file size is large compared to the maximum
window size, the measurement should be valid.  A file size of 1G is ver=
y
large compared to 128K.

