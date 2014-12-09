From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: use MAX_HEADER for headroom reserve in
 output path
Date: Tue, 09 Dec 2014 13:24:55 -0500 (EST)
Message-ID: <20141209.132455.111095755280708974.davem@davemloft.net>
References: <1417605238-9936-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	robert@swiecki.net
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaLISY6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:24:58 -0500
In-Reply-To: <1417605238-9936-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  3 Dec 2014 12:13:58 +0100

> To accomodate for enough headroom for tunnels, use MAX_HEADER instead
> of LL_MAX_HEADER. Robert reported that he has hit after roughly 40hrs
> of trinity an skb_under_panic() via SCTP output path (see reference).
> I couldn't reproduce it from here, but not using MAX_HEADER as elsewh=
ere
> in other protocols might be one possible cause for this.
>=20
> In any case, it looks like accounting on chunks themself seems to loo=
k
> good as the skb already passed the SCTP output path and did not hit
> any skb_over_panic(). Given tunneling was enabled in his .config, the
> headroom would have been expanded by MAX_HEADER in this case.
>=20
> Reported-by: Robert =A6wi=EAcki <robert@swiecki.net>
> Reference: https://lkml.org/lkml/2014/12/1/507
> Fixes: 594ccc14dfe4d ("[SCTP] Replace incorrect use of dev_alloc_skb =
with alloc_skb in sctp_packet_transmit().")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.
