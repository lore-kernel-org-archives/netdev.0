From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: fix bridge multicast packet checksum
	validation
Date: Thu, 18 Feb 2016 17:38:25 -0800
Message-ID: <20160218173825.3dca8d27@xeon-e3>
References: <1455502026-23144-1-git-send-email-linus.luessing@c0d3.blue>
	<20160218.153542.67284853154438064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, sgunderson@bigfoot.com, tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20160218.153542.67284853154438064.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Feb 2016 15:35:42 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
> Date: Mon, 15 Feb 2016 03:07:06 +0100
>=20
> > @@ -4084,10 +4089,22 @@ struct sk_buff *skb_checksum_trimmed(struct sk_=
buff *skb,
> >  	if (!pskb_may_pull(skb_chk, offset))
> >  		goto err;
> > =20
> > -	__skb_pull(skb_chk, offset);
> > +	ip_summed =3D skb->ip_summed;
> > +	csum_valid =3D skb->csum_valid;
> > +	csum_level =3D skb->csum_level;
> > +	csum_bad =3D skb->csum_bad;
> > +	csum =3D skb->csum;
> > +
> > +	skb_pull_rcsum(skb_chk, offset);
> >  	ret =3D skb_chkf(skb_chk);
> >  	__skb_push(skb_chk, offset);
> > =20
> > +	skb->ip_summed =3D ip_summed;
> > +	skb->csum_valid =3D csum_valid;
> > +	skb->csum_level =3D csum_level;
> > +	skb->csum_bad =3D csum_bad;
> > +	skb->csum =3D csum;
> > +
>=20
> There really has to be a better way to fix this :-/

Agreed, this is gross.
