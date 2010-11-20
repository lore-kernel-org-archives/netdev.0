From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: remove an atomic bit operation
Date: Sat, 20 Nov 2010 17:50:04 +0100
Message-ID: <1290271804.2756.78.camel@edumazet-laptop>
References: <1290239717-12664-1-git-send-email-xiaosuo@gmail.com>
	 <4CE7F160.9050107@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE7F160.9050107@canonical.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 20 novembre 2010 =C3=A0 09:03 -0700, Tim Gardner a =C3=A9crit=
 :
> On 11/20/2010 12:55 AM, Changli Gao wrote:
> > As this ct won't be seen by the others, we don't need to set the
> > IPS_CONFIRMED_BIT in atomic way.
> >
> > Signed-off-by: Changli Gao<xiaosuo@gmail.com>
> > ---
> >   net/netfilter/nf_conntrack_core.c |    2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_c=
onntrack_core.c
> > index 27a5ea6..c708248 100644
> > --- a/net/netfilter/nf_conntrack_core.c
> > +++ b/net/netfilter/nf_conntrack_core.c
> > @@ -486,7 +486,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
> >   	ct->timeout.expires +=3D jiffies;
> >   	add_timer(&ct->timeout);
> >   	atomic_inc(&ct->ct_general.use);
> > -	set_bit(IPS_CONFIRMED_BIT,&ct->status);
> > +	ct->status |=3D IPS_CONFIRMED_BIT;
> >
> >   	/* Since the lookup is lockless, hash insertion must be done aft=
er
> >   	 * starting the timer and setting the CONFIRMED bit. The RCU bar=
riers
> > --

> NAK, set_bit() takes a bit number, not a mask. That is, assuming you =
can=20
> get away with a non-atomic operation on this field. I'll defer to=20
> Patrick on that.
>=20
> I think you have to use IPS_CONFIRMED instead, e.g.,
>=20
> 	ct->status |=3D IPS_CONFIRMED;
>=20

Or

	__set_bit(IPS_CONFIRMED_BIT, &ct->status);


set_bit() is atomic, while __set_bit() is not



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
