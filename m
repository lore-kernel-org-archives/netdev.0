From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: add ethtool support to read and change
 RSS key
Date: Tue, 22 Sep 2015 16:34:45 -0700
Message-ID: <1442964885.29850.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442614912.14037.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150922.145935.2262486270670808983.davem@davemloft.net>
	 <20150922.160644.138485112664023430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35704 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759758AbbIVXer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 19:34:47 -0400
Received: by pacfv12 with SMTP id fv12so22785181pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 16:34:47 -0700 (PDT)
In-Reply-To: <20150922.160644.138485112664023430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-22 at 16:06 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 22 Sep 2015 14:59:35 -0700 (PDT)
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Fri, 18 Sep 2015 15:21:52 -0700
> >=20
> >> From: Eric Dumazet <edumazet@google.com>
> >>=20
> >> While trying to understand why bnx2x RSS hash was not matching
> >> Toeplitz specifications, I implemented driver code to support
> >> ethtool -x|-X to try various RSS key combinations easily.
> >>=20
> >> Then, after some debugging, I understood bnx2x was reading the rss=
_key
> >> in reverse order.
> >>=20
> >> If we want consistent Toeplitz hashes with different NIC, we need
> >> to byte swap user key.
> >>=20
> >> Tested:
> >  ...
> >> Signed-off-by: Eric Dumazet <edumazet@google.com>
> >=20
> > Applied, thanks Eric.
>=20
> Reverting, this doesn't compile:
>=20
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c: In function =E2=80=98=
bnx2x_vfpf_config_rss=E2=80=99:
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c:814:29: error: =E2=80=
=98struct bnx2x_config_rss_params=E2=80=99 has no member named =E2=80=98=
rss_key=E2=80=99
>   memcpy(req->rss_key, params->rss_key, sizeof(params->rss_key));
>                              ^
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c:814:53: error: =E2=80=
=98struct bnx2x_config_rss_params=E2=80=99 has no member named =E2=80=98=
rss_key=E2=80=99
>   memcpy(req->rss_key, params->rss_key, sizeof(params->rss_key));
>                                                      ^
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c: In function =E2=80=98=
bnx2x_vf_mbx_update_rss=E2=80=99:
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c:1988:12: error: =E2=80=
=98struct bnx2x_config_rss_params=E2=80=99 has no member named =E2=80=98=
rss_key=E2=80=99
>   memcpy(rss.rss_key, rss_tlv->rss_key, sizeof(rss_tlv->rss_key));
> =20

Ah sorry for this.

I'll submit the byte-swapping fix only separately.
