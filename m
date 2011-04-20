From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: tun: convert to hw_features
Date: Thu, 21 Apr 2011 01:15:03 +0200
Message-ID: <20110420231503.GA20775@rere.qmqm.pl>
References: <20110419161310.7508513909@rere.qmqm.pl> <871v0xip3j.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45581 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292Ab1DTXPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 19:15:05 -0400
Content-Disposition: inline
In-Reply-To: <871v0xip3j.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2011 at 12:52:24PM +0930, Rusty Russell wrote:
> On Tue, 19 Apr 2011 18:13:10 +0200 (CEST), Micha=B3 Miros=B3aw <mirq-=
linux@rere.qmqm.pl> wrote:
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
> Err, not in my git tree!  It predates git in fact.

Ah! Sorry! Your patch just moved the buggy line around.

> Since tap requires privs, I wouldn't worry about invalid packets too
> much.

I prefer correctness over uncertainty. ;)

Best Regards,
Micha=B3 Miros=B3aw
