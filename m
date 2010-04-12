From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v3 Patch 2/3] bridge: make bridge support netpoll
Date: Mon, 12 Apr 2010 12:38:57 +0200
Message-ID: <1271068737.16881.18.camel@edumazet-laptop>
References: <20100408062234.4499.17042.sendpatchset@localhost.localdomain>
	 <20100408062246.4499.5670.sendpatchset@localhost.localdomain>
	 <20100408083710.2b61ee44@nehalam>  <4BC2F7E2.7020309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>, Matt Mackall <mpm@selenic.com>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC2F7E2.7020309@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 12 avril 2010 =C3=A0 18:37 +0800, Cong Wang a =C3=A9crit :
> Stephen Hemminger wrote:
> > There is no protection on dev->priv_flags for SMP access.
> > It would better bit value in dev->state if you are using it as cont=
rol flag.
> >=20
> > Then you could use=20
> > 			if (unlikely(test_and_clear_bit(__IN_NETPOLL, &skb->dev->state))=
)
> > 				netpoll_send_skb(...)
> >=20
> >=20
>=20
> Hmm, I think we can't use ->state here, it is not for this kind of pu=
rpose,
> according to its comments.
>=20
> Also, I find other usages of IFF_XXX flags of ->priv_flags are also u=
sing
> &, | to set or clear the flags. So there must be some other things pr=
eventing
> the race...

Yes, its RTNL that protects priv_flags changes, hopefully...
