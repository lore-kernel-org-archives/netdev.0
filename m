From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: tun: convert to hw_features
Date: Wed, 27 Apr 2011 14:29:31 +0930
Message-ID: <87r58ol26k.fsf@rustcorp.com.au>
References: <20110419161310.7508513909@rere.qmqm.pl> <20110420.013216.28818575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51966 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976Ab1D0GHN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 02:07:13 -0400
In-Reply-To: <20110420.013216.28818575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Apr 2011 01:32:16 -0700 (PDT), David Miller <davem@davemloft=
=2Enet> wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Tue, 19 Apr 2011 18:13:10 +0200 (CEST)
>=20
> > This changes offload setting behaviour to what I think is correct:
> >  - offloads set via ethtool mean what admin wants to use (by defaul=
t
> >    he wants 'em all)
> >  - offloads set via ioctl() mean what userspace is expecting to get
> >    (this limits which admin wishes are granted)
> >  - TUN_NOCHECKSUM is ignored, as it might cause broken packets when
> >    forwarded (ip_summed =3D=3D CHECKSUM_UNNECESSARY means that chec=
ksum
> >    was verified, not that it can be ignored)
> >=20
> > If TUN_NOCHECKSUM is implemented, it should set skb->csum_* and
> > skb->ip_summed (=3D CHECKSUM_PARTIAL) for known protocols and let o=
thers
> > be verified by kernel when necessary.
> >=20
> > TUN_NOCHECKSUM handling was introduced by commit
> > f43798c27684ab925adde7d8acc34c78c6e50df8:
> >=20
> >     tun: Allow GSO using virtio_net_hdr
> >    =20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Applied.

Dave, you just removed a feature that has been in Linux since before
git.  It *probably* just means we go slower in cases we don't really
care about.  But does removing it break qemu?  Has anyone tested?

Thanks,
Rusty.

