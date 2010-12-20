From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 11:41:11 +0100
Message-ID: <1292841671.2800.11.camel@edumazet-laptop>
References: <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
	 <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com>
	 <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com>
	 <4D0F0D73.2080807@itcare.pl>
	 <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com>
	 <1292836097.2800.3.camel@edumazet-laptop>
	 <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
	 <1292836885.2800.4.camel@edumazet-laptop>
	 <20101220103226.GB7977@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	=?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43842 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab0LTKlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 05:41:15 -0500
Received: by wyb28 with SMTP id 28so2697590wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 02:41:14 -0800 (PST)
In-Reply-To: <20101220103226.GB7977@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 10:32 +0000, Jarek Poplawski a =C3=
=A9crit :
> On Mon, Dec 20, 2010 at 10:21:25AM +0100, Eric Dumazet wrote:
> > Le lundi 20 d=C3=A9cembre 2010 ?? 17:11 +0800, Changli Gao a =C3=A9=
crit :
> > > Yes, you are right. I just wonder where shared skbs are allowed. =
Is
> > > there any rule?
> > >=20
> >=20
> > Shared skbs are allowed for sure (pktgen is a provider of such skbs=
).
>=20
> But pktgen doesn't use common dev_queue_xmit() path. It looks like
> some places checking segmentation call pskb_expand_head() assuming sk=
b
> isn't shared. Btw, it seems ifb should have GSO features similarly to
> loopback. Anyway, until all this is verified, IMHO we should revert
> Changli's mirred patch in stable.
>=20

I thought Changli question was : is a skb given to a device
ndo_start_xmit() handler is allowed to be shared ;)

I believe Changli patch should be reverted, because not doing a
skb_clone() should be known by caller.

To avoid the skb_clone(), we must tell caller what we did, so that
caller dont even try to reuse skb (even freeing it)




