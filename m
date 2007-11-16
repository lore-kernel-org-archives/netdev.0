From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/10] [TCP]: non-FACK SACK follows conservative SACK
 loss recovery
Date: Thu, 15 Nov 2007 19:41:15 -0800 (PST)
Message-ID: <20071115.194115.255442199.davem@davemloft.net>
References: <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37058
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757372AbXKPDlP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:41:15 -0500
In-Reply-To: <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:27 +0200

> Many assumptions that are true when no reordering or other
> strange events happen are not a part of the RFC3517. FACK
> implementation is based on such assumptions. Previously (before
> the rewrite) the non-FACK SACK was basically doing fast rexmit
> and then it times out all skbs when first cumulative ACK arrives,
> which cannot really be called SACK based recovery :-).
>=20
> RFC3517 SACK disables these things:
> - Per SKB timeouts & head timeout entry to recovery
> - Marking at least one skb while in recovery (RFC3517 does this
>   only for the fast retransmission but not for the other skbs
>   when cumulative ACKs arrive in the recovery)
> - Sacktag's loss detection flavors B and C (see comment before
>   tcp_sacktag_write_queue)
>=20
> This does not implement the "last resort" rule 3 of NextSeg, which
> allows retransmissions also when not enough SACK blocks have yet
> arrived above a segment for IsLost to return true [RFC3517].
>=20
> The implementation differs from RFC3517 in these points:
> - Rate-halving is used instead of FlightSize / 2
> - Instead of using dupACKs to trigger the recovery, the number
>   of SACK blocks is used as FACK does with SACK blocks+holes
>   (which provides more accurate number). It seems that the
>   difference can affect negatively only if the receiver does not
>   generate SACK blocks at all even though it claimed to be
>   SACK-capable.
> - Dupthresh is not a constant one. Dynamical adjustments include
>   both holes and sacked segments (equal to what FACK has) due to
>   complexity involved in determining the number sacked blocks
>   between highest_sack and the reordered segment. Thus it's will
>   be an over-estimate.
>=20
> Implementation note:
>=20
> tcp_clean_rtx_queue doesn't need a lost_cnt tweak because head
> skb at that point cannot be SACKED_ACKED (nor would such
> situation last for long enough to cause problems).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks a lot for doing this work, these changes look fine to
me.

It occurs to me that the loss engine basically runs in about
2 or 3 modes, and instead of making the same tests multiple
times through the ACK processing paths we might want to move
to some kind of 'tcp_loss_ops' scheme.

It is just an idea.

Patch applied to net-2.6.25, thanks!
