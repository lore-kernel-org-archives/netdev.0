From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net dst: fix percpu_counter list corruption and poison
 overwritten
Date: Wed, 03 Nov 2010 06:22:53 +0100
Message-ID: <1288761773.2467.535.camel@edumazet-laptop>
References: <1288750265-17664-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63674 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab0KCFXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 01:23:02 -0400
In-Reply-To: <1288750265-17664-1-git-send-email-dfeng@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 novembre 2010 =C3=A0 10:11 +0800, Xiaotian Feng a =C3=A9=
crit :
> There're some percpu_counter list corruption and poison overwritten w=
arnings
> in recent kernel, which is resulted by fc66f95c.
>=20
> commit fc66f95c switches to use percpu_counter, in ip6_route_net_init=
, kernel
> init the percpu_counter for dst entries, but, the percpu_counter is n=
ever destroyed
> in ip6_route_net_exit. So if the related data is freed by kernel, the=
 freed percpu_counter
> is still on the list, then if we insert/remove other percpu_counter, =
list corruption
> resulted. Also, if the insert/remove option modifies the ->prev,->nex=
t pointer of
> the freed value, the poison overwritten is resulted then.
>=20
> With the following patch, the percpu_counter list corruption and pois=
on overwritten
> warnings disappeared.
>=20
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> ---

Good catch, thanks !

Any reason you didnt Cc me (the author of the patch) ?

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



