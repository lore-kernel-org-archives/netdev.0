From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH 11/14] netlink: add RX/TX-ring support to netlink diag
Date: Tue, 23 Apr 2013 20:28:35 +0200
Message-ID: <3020335.4HTe7KSVvr@cpaasch-mac>
References: <1366217229-22705-1-git-send-email-kaber@trash.net> <1366217229-22705-12-git-send-email-kaber@trash.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:47627 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756910Ab3DWS2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 14:28:40 -0400
In-Reply-To: <1366217229-22705-12-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wednesday 17 April 2013 18:47:06 Patrick McHardy wrote:
> +       mutex_lock(&nlk->pg_vec_lock);
> +       ret =3D sk_diag_put_ring(&nlk->rx_ring, NETLINK_DIAG_RX_RING,=
 nlskb);
> +       if (!ret)
> +               ret =3D sk_diag_put_ring(&nlk->tx_ring, NETLINK_DIAG_=
TX_RING,
> +                                      nlskb);
> +       mutex_unlock(&nlk->pg_vec_lock);

this produces a build-error, if CONFIG_NETLINK_MMAP=3Dn:

/home/cpaasch/builder/net-next/net/netlink/diag.c: In function=20
=E2=80=98sk_diag_put_rings_cfg=E2=80=99:
/home/cpaasch/builder/net-next/net/netlink/diag.c:28: error: =E2=80=98s=
truct=20
netlink_sock=E2=80=99 has no member named =E2=80=98pg_vec_lock=E2=80=99
/home/cpaasch/builder/net-next/net/netlink/diag.c:29: error: =E2=80=98s=
truct=20
netlink_sock=E2=80=99 has no member named =E2=80=98rx_ring=E2=80=99


Should the #ifdef CONFIG_NETLINK_MMAP in struct netlink_sock be removed=
?


Cheers,
Christoph


--=20
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
