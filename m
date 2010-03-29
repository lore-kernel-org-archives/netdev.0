From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 02/12] l2tp: Split pppol2tp patch into separate l2tp
 and ppp parts
Date: Mon, 29 Mar 2010 12:18:16 +0200
Message-ID: <1269857896.2164.10.camel@edumazet-laptop>
References: <20100329095639.30460.30496.stgit@bert.katalix.com>
	 <20100329095650.30460.79849.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:45272 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab0C2KSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 06:18:20 -0400
Received: by bwz1 with SMTP id 1so3418850bwz.21
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 03:18:18 -0700 (PDT)
In-Reply-To: <20100329095650.30460.79849.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 10:56 +0100, James Chapman a =C3=A9crit :

> +
> +/* Session hash list.
> + * The session_id SHOULD be random according to RFC2661, but several
> + * L2TP implementations (Cisco and Microsoft) use incrementing
> + * session_ids.  So we do a real hash on the session_id, rather than=
 a
> + * simple bitmask.
> + */
> +static inline struct hlist_head *
> +l2tp_session_id_hash(struct l2tp_tunnel *tunnel, u32 session_id)
> +{
> +	unsigned long hash_val =3D (unsigned long) session_id;
> +	return &tunnel->session_hlist[hash_long(hash_val, L2TP_HASH_BITS)];
> +}

Please use hash_32() here, its better in this case on 64 bit arches (32
bits in session_id)

return &tunnel->session_hlist[hash_32(session_id, L2TP_HASH_BITS)];



