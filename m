From: =?iso-8859-2?Q?Micha=B3Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 17:18:31 +0100
Message-ID: <20101130161831.GA28788@rere.qmqm.pl>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl> <1291130005.21077.18.camel@bwh-desktop> <20101130152838.GA26281@rere.qmqm.pl> <1291132318.21077.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33177 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab0K3QSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 11:18:33 -0500
Content-Disposition: inline
In-Reply-To: <1291132318.21077.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 03:51:58PM +0000, Ben Hutchings wrote:
> > > Why are you disabling IPv6 checksum offload?  From a quick look a=
t the
> > > driver, I think the hardware does support it.
> >=20
> > In vxge_xmit() (at drivers/net/vxge/vxge-main.c:922 in net-next) th=
ere
> > is the following code, that suggested otherwise:
> >=20
> >         if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
> >                 vxge_hw_fifo_txdl_cksum_set_bits(dtr,
> >                                         VXGE_HW_FIFO_TXD_TX_CKO_IPV=
4_EN |
> >                                         VXGE_HW_FIFO_TXD_TX_CKO_TCP=
_EN |
> >                                         VXGE_HW_FIFO_TXD_TX_CKO_UDP=
_EN);
>=20
> I bet IPV4_EN refers to the IPv4 header checksum.  Since IPv6 doesn't
> have a header checksum, there won't be a flag for it here.

That makes sense. I'll fix that.

Thanks,
Micha=B3 Miros=B3aw
