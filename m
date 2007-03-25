From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv5 5/5] [TCP]: non-FACK SACK follows conservative
 SACK loss recovery (RFC3517)
Date: Sat, 24 Mar 2007 21:13:07 -0700 (PDT)
Message-ID: <20070324.211307.59653456.davem@davemloft.net>
References: <1174070466450-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11740704661086-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11740704662402-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39870
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965052AbXCYENI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 00:13:08 -0400
In-Reply-To: <11740704662402-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 16 Mar 2007 20:41:06 +0200

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
> - B & C flavors of loss detection (see comment before
>   tcp_sacktag_write_queue)
>=20
> This does not implement the "last resort" rule 3 of NextSeg, which
> allows retransmissions also when not enough SACK blocks have yet
> arrived above a segment for IsLost to return true [RFC3517].
>=20
> The implementation differs from RFC3517 in two points:
> - Rate-halving is used instead of FlightSize / 2
> - Instead of using dupACKs to trigger the recovery, the number
>   of SACK blocks is used as FACK does with SACK blocks+holes
>   (which provides more accurate number). It seems that the
>   difference can affect negatively only if the receiver does not
>   generate SACK blocks at all even though it claimed to be
>   SACK-capable.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I'm OK with this one too, applied, thanks a lot!
