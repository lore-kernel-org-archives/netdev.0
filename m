From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Mon, 11 Oct 2010 17:46:49 +0200
Message-ID: <1286812009.2737.30.camel@edumazet-laptop>
References: <1286810413-30238-1-git-send-email-avagin@openvz.org>
	 <4CB32FDB.4090001@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrey Vagin <avagin@openvz.org>, stable@kernel.org,
	netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53383 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755280Ab0JKPrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 11:47:01 -0400
Received: by wye20 with SMTP id 20so565589wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 08:47:00 -0700 (PDT)
In-Reply-To: <4CB32FDB.4090001@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 19:40 +0400, Michael Tokarev a =C3=A9cr=
it :
> Andrey Vagin wrote:
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >=20
> > commit 068a2de57ddf4f472e32e7af868613c574ad1d88 upstream.
> >=20
> > Non-GSO code drops dst entry for performance reasons, but
> > the same is missing for GSO code. Drop dst while cache-hot
> > for GSO case too.
> >=20
> > Note: Without this patch the kernel may oops if used bridged veth
> > devices. A bridge set skb->dst =3D fake_dst_ops, veth transfers thi=
s skb
> > to netif_receive_skb...ip_rcv_finish and it calls dst_input(skb), b=
ut
> > fake_dst_ops->input =3D NULL -> Oops
>=20
> Hmm.  Isn't this the reason for my mysterious OOPSes (jump to
> NULL) which I concluded are due to stack overflow?  See f.e.
> http://www.spinics.net/lists/netdev/msg142104.html
>=20
> This started happening when I updated virtio drivers in a windows
> virtual machne to the ones which supports GSO, and my config
> involves bridging veth devices, and this is where the prob
> actually occurs - when doing guest =3D> virtio =3D> tap =3D> bridge =3D=
> veth
> route....
>=20
> Thanks!

This patch was an optimization, not a bug fix.

If something gets better, then a bug is somewhere else ?



