From: Florian Westphal <fw@strlen.de>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sat, 21 Feb 2015 18:46:25 +0100
Message-ID: <20150221174625.GA29681@breakpoint.cc>
References: <20150203100816.GA5807@louise.pinerecords.com>
 <20150203104214.GG24751@breakpoint.cc>
 <20150210154536.GB16264@breakpoint.cc>
 <20150221101512.GB17223@louise.pinerecords.com>
 <20150221103104.GA26574@breakpoint.cc>
 <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>,
	Tomas Szepe <szepe@pinerecords.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34724 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751841AbbBURqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 12:46:34 -0500
Content-Disposition: inline
In-Reply-To: <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hold on.
>=20
> I believe there is one race in the way you access skb->xmit_more _aft=
er_
>=20
> txd->opts1 =3D cpu_to_le32(status);
>=20
> After this point, TX might have completed and TX completion already h=
ave
> freed skb

Hmm, I _thought_ HW would not start xmit of this descriptor/skb until a=
fter

RTL_W8(TxPoll, NPQ);

call a bit later... your patch surely looks safer though, thanks for
looking into this.

> Could Tomas try following fix ?

In addition -- Tomas, on your affected board -- did you try
turning off gso/tso?

Holger Hoffst=E4tte mentioned on lkml that his affected r8169 nic is
stable with xmit_more+bql after disabling gso/tso on the nic

(ethtool -k $dev to display settings, "-K $dev tso off gso off" to
 disable offloads).
