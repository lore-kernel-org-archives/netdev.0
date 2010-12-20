From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 10:32:27 +0000
Message-ID: <20101220103226.GB7977@ff.dom.local>
References: <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com> <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com> <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com> <4D0F0D73.2080807@itcare.pl> <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com> <1292836097.2800.3.camel@edumazet-laptop> <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com> <1292836885.2800.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:50028 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab0LTKcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 05:32:31 -0500
Received: by fxm18 with SMTP id 18so2845935fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 02:32:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292836885.2800.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 10:21:25AM +0100, Eric Dumazet wrote:
> Le lundi 20 d=E9cembre 2010 ?? 17:11 +0800, Changli Gao a =E9crit :
> > Yes, you are right. I just wonder where shared skbs are allowed. Is
> > there any rule?
> >=20
>=20
> Shared skbs are allowed for sure (pktgen is a provider of such skbs).

But pktgen doesn't use common dev_queue_xmit() path. It looks like
some places checking segmentation call pskb_expand_head() assuming skb
isn't shared. Btw, it seems ifb should have GSO features similarly to
loopback. Anyway, until all this is verified, IMHO we should revert
Changli's mirred patch in stable.

Jarek P.
