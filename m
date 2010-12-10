From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V2 5/5] Add TX zero copy in macvtap
Date: Fri, 10 Dec 2010 11:27:44 +0100
Message-ID: <1291976864.3580.7.camel@edumazet-laptop>
References: <1291976026.2167.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com, xiaohui.xin@intel.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291976026.2167.49.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 02:13 -0800, Shirley Ma a =C3=A9=
crit :

> +		while (len) {
> +			f =3D &skb_shinfo(skb)->frags[i];
> +			f->page =3D page[i];
> +			f->page_offset =3D base & ~PAGE_MASK;
> +			f->size =3D min_t(int, len, PAGE_SIZE - f->page_offset);
> +			skb->data_len +=3D f->size;
> +			skb->len +=3D f->size;
> +			skb->truesize +=3D f->size;
> +			skb_shinfo(skb)->nr_frags++;
> +			/* increase sk_wmem_alloc */
> +			atomic_add(f->size, &skb->sk->sk_wmem_alloc);
> +			base +=3D f->size;
> +			len -=3D f->size;
> +			i++;
> +		}

You could make one atomic_add() outside of the loop, and factorize many
things...

atomic_add(len, &skb->sk->sk_wmem_alloc);
skb->data_len +=3D len;
skb->len +=3D len;
skb->truesize +=3D len;
while (len) {
	...
}
