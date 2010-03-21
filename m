From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Netfilter: Fix integer overflow in
 net/ipv6/netfilter/ip6_tables.c (fwd)
Date: Sun, 21 Mar 2010 22:59:34 +0100
Message-ID: <1269208774.3004.15.camel@edumazet-laptop>
References: <alpine.LRH.2.00.1003220850180.3232@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:64260 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab0CUV7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 17:59:44 -0400
Received: by bwz3 with SMTP id 3so4835207bwz.29
        for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 14:59:42 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1003220850180.3232@tundra.namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 mars 2010 =C3=A0 08:50 +1100, James Morris a =C3=A9crit :
> ---------- Forwarded message ----------
> Date: Sat, 20 Mar 2010 22:32:40 +0800
> From: wzt.wzt@gmail.com
> To: linux-kernel@vger.kernel.org
> Cc: netfilter-devel@vger.kernel.org, kaber@trash.net
> Subject: [PATCH] Netfilter: Fix integer overflow in
>     net/ipv6/netfilter/ip6_tables.c
>=20
> The get.size field in the get_entries() interface is not bounded
> correctly. The size is used to determine the total entry size.
> The size is bounded, but can overflow and so the size checks may
> not be sufficient to catch invalid size. Fix it by catching size
> values that would cause overflows before calculating the size.
>=20
> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
>=20


Unless I am wrong, this patch is not necessary, since we do a bit
later :


                if (get.size =3D=3D private->size)
                        ret =3D copy_entries_to_user(private->size,
                                                   t, uptr->entrytable)=
;
                else {
                        duprintf("get_entries: I've got %u not %u!\n",
                                 private->size, get.size);
                        ret =3D -EAGAIN;
                }

So if get.size doesnt match private->size (kernel certified), we exit
with an error. No calculation, no overflow involved.



