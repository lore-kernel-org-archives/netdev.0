From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net, v2] gre: fix the inner mac header in nbma tunnel
 xmit path
Date: Mon, 15 Dec 2014 11:46:32 -0500 (EST)
Message-ID: <20141215.114632.925120976146731438.davem@davemloft.net>
References: <20141211.150706.1736198745550279282.davem@davemloft.net>
	<1418628253-4950-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com,
	alexander.h.duyck@redhat.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaLOQqe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 11:46:34 -0500
In-Reply-To: <1418628253-4950-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Mon, 15 Dec 2014 09:24:13 +0200

> The NBMA GRE tunnels temporarily push GRE header that contain the
> per-packet NBMA destination on the skb via header ops early in xmit
> path. It is the later pulled before the real GRE header is constructe=
d.
>=20
> The inner mac was thus set differently in nbma case: the GRE header
> has been pushed by neighbor layer, and mac header points to beginning
> of the temporary gre header (set by dev_queue_xmit).
>=20
> Now that the offloads expect mac header to point to the gre payload,
> fix the xmit patch to:
>  - pull first the temporary gre header away
>  - and reset mac header to point to gre payload
>=20
> This fixes tso to work again with nbma tunnels.
>=20
> Fixes: 14051f0452a2 ("gre: Use inner mac length when computing tunnel=
 length")
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied and queued up for -stable, thanks.
