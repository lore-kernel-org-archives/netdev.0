From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 11:11:41 +0000
Message-ID: <20101220111141.GC7977@ff.dom.local>
References: <4D0E8416.2030100@gmail.com> <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com> <4D0F0D73.2080807@itcare.pl> <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com> <1292836097.2800.3.camel@edumazet-laptop> <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com> <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local> <1292841671.2800.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:36726 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab0LTLLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 06:11:45 -0500
Received: by bwz16 with SMTP id 16so3147384bwz.4
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 03:11:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292841671.2800.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 11:41:11AM +0100, Eric Dumazet wrote:
> Le lundi 20 d=E9cembre 2010 ?? 10:32 +0000, Jarek Poplawski a =E9crit=
 :
> > On Mon, Dec 20, 2010 at 10:21:25AM +0100, Eric Dumazet wrote:
> > > Le lundi 20 d=E9cembre 2010 ?? 17:11 +0800, Changli Gao a =E9crit=
 :
> > > > Yes, you are right. I just wonder where shared skbs are allowed=
=2E Is
> > > > there any rule?
> > > >=20
> > >=20
> > > Shared skbs are allowed for sure (pktgen is a provider of such sk=
bs).
> >=20
> > But pktgen doesn't use common dev_queue_xmit() path. It looks like
> > some places checking segmentation call pskb_expand_head() assuming =
skb
> > isn't shared. Btw, it seems ifb should have GSO features similarly =
to
> > loopback. Anyway, until all this is verified, IMHO we should revert
> > Changli's mirred patch in stable.
> >=20
>=20
> I thought Changli question was : is a skb given to a device
> ndo_start_xmit() handler is allowed to be shared ;)
>=20
> I believe Changli patch should be reverted, because not doing a
> skb_clone() should be known by caller.
>=20
> To avoid the skb_clone(), we must tell caller what we did, so that
> caller dont even try to reuse skb (even freeing it)

To tell the truth, Changli could assume we don't need to tell anything,
because this mirred skb is almost not shared (except the refcount ;-).

Jarek P.
