From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5 v2] net: add old_queue_mapping into skb->cb
Date: Wed, 15 Dec 2010 08:13:22 +0100
Message-ID: <1292397202.2377.13.camel@edumazet-laptop>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41484 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057Ab0LOHN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:13:26 -0500
Received: by wyb28 with SMTP id 28so1187385wyb.19
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:13:25 -0800 (PST)
In-Reply-To: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 13:23 +0800, Changli Gao a =C3=
=A9crit :
> For the skbs returned from ifb, we should use the queue_mapping
> saved before ifb.
>=20
> We save old queue_mapping in old_queue_mapping just before calling=20
> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
> just before reinjecting the skb.
>=20
> dev_pick_tx() use the current queue_mapping for the skbs reinjected
> by ifb.
>=20
> A new struct dev_skb_cb is added, and valid in qdisc and gso layer.
> The original qdisc_skb_cb and DEV_GSO_CB are placed after dev_skb_cb.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

This is really ugly and error prone.

Could you just use a more normal way to express this ?


struct ifb_save_fields_cb {
	u16 queue_mapping;
};

struct napi_gro_cb {
	struct ifb_save_fields_cb ifb_cb; /* needed by ifb, must be first */
	...
}


struct qdisc_skb_cb {
	struct ifb_save_fields_cb ifb_cb; /* needed by ifb, must be first */
	unsigned int	pkt_len;
};



