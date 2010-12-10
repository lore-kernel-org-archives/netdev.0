From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V2 5/5] Add TX zero copy in macvtap
Date: Fri, 10 Dec 2010 17:55:06 +0100
Message-ID: <1292000106.3580.210.camel@edumazet-laptop>
References: <1291976026.2167.49.camel@localhost.localdomain>
	 <1291976864.3580.7.camel@edumazet-laptop>
	 <1291998355.2167.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com, xiaohui.xin@intel.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291998355.2167.53.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 08:25 -0800, Shirley Ma a =C3=A9=
crit :
> On Fri, 2010-12-10 at 11:27 +0100, Eric Dumazet wrote:
> > You could make one atomic_add() outside of the loop, and factorize
> > many
> > things...
> >=20
> > atomic_add(len, &skb->sk->sk_wmem_alloc);
> > skb->data_len +=3D len;
> > skb->len +=3D len;
> > skb->truesize +=3D len;
> > while (len) {
> >         ...
> > }=20
>=20
> Yep, thanks, will update it!

Also take a look at skb_fill_page_desc() helper, and maybe
skb_add_rx_frag() too.

The atomic op should be factorized for sure, but other adds might be
done by helpers to keep code short.
