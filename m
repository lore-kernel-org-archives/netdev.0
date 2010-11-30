From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] af_packet: replace struct pgv with char **
Date: Tue, 30 Nov 2010 15:16:08 +0100
Message-ID: <1291126568.2904.85.camel@edumazet-laptop>
References: <1291125457-14427-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56125 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289Ab0K3OQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 09:16:13 -0500
Received: by wyb28 with SMTP id 28so5737138wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 06:16:12 -0800 (PST)
In-Reply-To: <1291125457-14427-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 21:57 +0800, Changli Gao a =C3=A9crit =
:
> As we can check if an address is vmalloc address with is_vmalloc_addr=
(),
> we can replace struct pgv with char **. Then we may get more pg_vecs.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/packet/af_packet.c |   50 ++++++++++++++++----------------------=
-----------
>  1 file changed, 17 insertions(+), 33 deletions(-)
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 0171b20..a26f981 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -164,14 +164,8 @@ struct packet_mreq_max {
>  static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
>  		int closing, int tx_ring);
> =20
> -#define PGV_FROM_VMALLOC 1
> -struct pgv {
> -	char *buffer;
> -	unsigned char flags;
> -};
> -

This patch is premature.

Also, keep the struct pgv, even if it has a single field, since having
types is good to read the sources.

We could have 'void *' or 'char *' everywhere, it is not nice...


-       pg_vec =3D kcalloc(block_nr, sizeof(struct pgv), GFP_KERNEL);
+       pg_vec =3D kcalloc(block_nr, sizeof(char *), GFP_KERNEL);

I prefer to have :

       pg_vec =3D kcalloc(block_nr, sizeof(struct pgv), GFP_KERNEL);


