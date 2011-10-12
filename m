From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: hold sock reference while processing tx
 timestamps
Date: Wed, 12 Oct 2011 21:25:20 +0200
Message-ID: <1318447520.2644.4.camel@edumazet-laptop>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>, stable@kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63077 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab1JLTZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 15:25:26 -0400
Received: by wwf22 with SMTP id 22so543363wwf.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 12:25:25 -0700 (PDT)
In-Reply-To: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 octobre 2011 =C3=A0 20:36 +0200, Richard Cochran a =C3=A9=
crit :
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
> ---

Seems fine to me, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
