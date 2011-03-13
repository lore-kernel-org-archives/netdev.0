From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Sun, 13 Mar 2011 18:41:32 +0100
Message-ID: <1300038092.2761.41.camel@edumazet-laptop>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	 <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	 <20110313150646.GA30494@redhat.com>
	 <1300031570.2761.22.camel@edumazet-laptop>
	 <20110313161915.GB30642@redhat.com>
	 <1300033927.2761.26.camel@edumazet-laptop>
	 <20110313164359.GA32562@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110313164359.GA32562@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 13 mars 2011 =C3=A0 18:43 +0200, Michael S. Tsirkin a =C3=A9=
crit :
> On Sun, Mar 13, 2011 at 05:32:07PM +0100, Eric Dumazet wrote:
> > Le dimanche 13 mars 2011 =C3=A0 18:19 +0200, Michael S. Tsirkin a =C3=
=A9crit :
> >=20
> > > Other side is in drivers/net/tun.c and net/packet/af_packet.c
> > > At least wrt tun it seems clear socket is not locked.
> >=20
> > Yes (assuming you refer to tun_net_xmit())
> >=20
> > > Besides queue, dequeue seems to be done without socket locked.
> > >=20
> >=20
> > It seems this code (assuming you speak of drivers/vhost/net.c ?) ha=
s
> > some races indeed.
> >=20
>=20
> Hmm. Any more besides the one fixed here?
>=20

If writers and readers dont share a common lock, how can they reliably
synchronize states ?

=46or example, the check at line 420 seems unsafe or useless.

skb_queue_empty(&sock->sk->sk_receive_queue)
