From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] tcp: allow undo from reordered DSACKs
Date: Sun, 27 Nov 2011 18:58:57 -0500 (EST)
Message-ID: <20111127.185857.475440859115872225.davem@davemloft.net>
References: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
	<CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
	<alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab1K0X7K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 18:59:10 -0500
In-Reply-To: <alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 22 Nov 2011 14:44:32 +0200 (EET)

> On Thu, 17 Nov 2011, Neal Cardwell wrote:
>=20
>> On Thu, Nov 17, 2011 at 12:18 AM, Ilpo J=E4rvinen
>> <ilpo.jarvinen@helsinki.fi> wrote:
>> > On Wed, 16 Nov 2011, Neal Cardwell wrote:
>> >
>> >> Previously, SACK-enabled connections hung around in TCP_CA_Disord=
er
>> >> state while snd_una=3D=3Dhigh_seq, just waiting to accumulate DSA=
CKs and
>> >> hopefully undo a cwnd reduction. This could and did lead to the
>> >> following unfortunate scenario: if some incoming ACKs advance snd=
_una
>> >> beyond high_seq then we were setting undo_marker to 0 and moving =
to
>> >> TCP_CA_Open, so if (due to reordering in the ACK return path) we
>> >> shortly thereafter received a DSACK then we were no longer able t=
o
>> >> undo the cwnd reduction.
>> >>
>> >> The change: Simplify the congestion avoidance state machine by
>> >> removing the behavior where SACK-enabled connections hung around =
in
>> >> the TCP_CA_Disorder state just waiting for DSACKs. Instead, when
>> >> snd_una advances to high_seq or beyond we typically move to
>> >> TCP_CA_Open immediately and allow an undo in either TCP_CA_Open o=
r
>> >> TCP_CA_Disorder if we later receive enough DSACKs.
>> >>
>> >> Other patches in this series will provide other changes that are
>> >> necessary to fully fix this problem.
>> >>
>> >> Signed-off-by: Neal Cardwell <ncardwell@google.com>
 ...
>> > How about extending Disorder state until second cumulative ACK tha=
t is
>> > acking >=3D high_seq?
>>=20
>> That would seem to add complexity but only provide a partial solutio=
n.
>=20
> Right, I forgot the reordering.

In order to make forward progress I've added Neil's patch to net-next.

> Also, one (serious) word of caution! This change, by its extending of=
=20
> CA_Open state, is somewhat similar to what I made FRTO years ago, and=
=20
> managed to introduces subtle breaking to the state machine. Please ch=
eck=20
> that the problem similar to what was fixed by=20
> a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (possibly =
in=20
> some other form causing spurious undos). ...To me it seems that=20
> tcp_packet_delayed might be similarly confused after the given patch.

Neil, please look into this so we can have any such issues fixed
in time for the next merge window.

Thanks.
