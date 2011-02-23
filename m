From: Neil Horman <nhorman@redhat.com>
Subject: Re: [V4 PATCH 3/3] bond: service netpoll arp queue on master device
Date: Wed, 23 Feb 2011 10:30:41 -0500
Message-ID: <20110223153041.GE11496@hmsreliant.think-freely.org>
References: <1298022215-21059-1-git-send-email-amwang@redhat.com>
 <1298022215-21059-3-git-send-email-amwang@redhat.com>
 <4D6526BD.6030306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D6526BD.6030306@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 11:24:45PM +0800, Cong Wang wrote:
> Neil, ping. :)
>=20
> =E4=BA=8E 2011=E5=B9=B402=E6=9C=8818=E6=97=A5 17:43, Amerigo Wang =E5=
=86=99=E9=81=93:
> >Neil pointed out that we can't send ARP reply on behalf of slaves,
> >we need to move the arp queue to their bond device.
> >
> >Signed-off-by: WANG Cong<amwang@redhat.com>
> >Cc: Neil Horman<nhorman@redhat.com>
> >
> >---
> >  net/core/netpoll.c |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> >
> >diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> >index f68e694..013e04a 100644
> >--- a/net/core/netpoll.c
> >+++ b/net/core/netpoll.c
> >@@ -193,6 +193,15 @@ void netpoll_poll_dev(struct net_device *dev)
> >
> >  	poll_napi(dev);
> >
> >+	if (dev->priv_flags&  IFF_SLAVE) {
> >+		if (dev->npinfo) {
> >+			struct net_device *bond_dev =3D dev->master;
> >+			struct sk_buff *skb;
> >+			while ((skb =3D skb_dequeue(&dev->npinfo->arp_tx)))
> >+				skb_queue_tail(&bond_dev->npinfo->arp_tx, skb);
> >+		}
> >+	}
> >+
> >  	service_arp_queue(dev->npinfo);
> >
> >  	zap_completion_queue();
>=20
>=20
> --=20
> =E6=88=91=E8=AE=A4=E8=AF=86=E7=9A=84=E4=BA=BA=E8=B6=8A=E5=A4=9A=EF=BC=
=8C=E6=88=91=E5=B0=B1=E8=B6=8A=E5=96=9C=E6=AC=A2=E7=8B=97=E3=80=82

seems reasonable, thanks!
Acked-by: Neil Horman <nhorman@tuxdriver.com>
