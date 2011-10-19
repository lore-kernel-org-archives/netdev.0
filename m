From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] net: hold sock reference while processing tx
 timestamps
Date: Wed, 19 Oct 2011 06:42:10 +0200
Message-ID: <1318999330.19139.19.camel@edumazet-laptop>
References: <cover.1318498805.git.richard.cochran@omicron.at>
	 <a9a9d4c4fbd872c8a5aa46cf412bdcb07617b00a.1318498805.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>, stable@kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59022 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab1JSEmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:42:19 -0400
Received: by wwe6 with SMTP id 6so1926446wwe.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 21:42:17 -0700 (PDT)
In-Reply-To: <a9a9d4c4fbd872c8a5aa46cf412bdcb07617b00a.1318498805.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 11:46 +0200, Richard Cochran a =C3=A9cr=
it :
> The pair of functions,
>=20
>  * skb_clone_tx_timestamp()
>  * skb_complete_tx_timestamp()
>=20
> were designed to allow timestamping in PHY devices. The first
> function, called during the MAC driver's hard_xmit method, identifies
> PTP protocol packets, clones them, and gives them to the PHY device
> driver. The PHY driver may hold onto the packet and deliver it at a
> later time using the second function, which adds the packet to the
> socket's error queue.
>=20
> As pointed out by Johannes, nothing prevents the socket from
> disappearing while the cloned packet is sitting in the PHY driver
> awaiting a timestamp. This patch fixes the issue by taking a referenc=
e
> on the socket for each such packet. In addition, the comments
> regarding the usage of these function are expanded to highlight the
> rule that PHY drivers must use skb_complete_tx_timestamp() to release
> the packet, in order to release the socket reference, too.
>=20
> These functions first appeared in v2.6.36.
>=20
> Reported-by: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Cc: <stable@kernel.org>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
