From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question]Why a skb with frag_list causes BUG_ON in function
 skb_segment
Date: Thu, 30 Jul 2015 07:01:01 +0200
Message-ID: <1438232461.20182.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <60A73B7A161A82449A7DB7B382BFD1553712AF1C@SZXEMA504-MBS.china.huawei.com>
	 <55B9A76A.3030908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Zhangjie (HZ)" <zhangjie14@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	Qinchuanyu <qinchuanyu@huawei.com>, Yewudi <yewudi@huawei.com>,
	liuyongan 00175866 <l00175866@notesmail.huawei.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B9A76A.3030908@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-30 at 12:26 +0800, Jason Wang wrote:
> cc netdev for more experts
>=20
> On 07/28/2015 04:53 PM, Zhangjie (HZ) wrote:
> >
> > Hi,
> >
> > I generate a skb as follows:
> >
> > It has a linear data region, 17 frags and the last fragment is in
> > skb_shinfo(skb)->frag_list.
> >
> > Before this skb is sent to driver, dev_hard_start_xmit() will segme=
nt
> > it first(skb has frag_list,
> >
> > so we get true from netif_needs_gso()), then the skb is passed to
> > function skb_segment().
> >
> > Then, BUG_ON() happened.
> >
> > while (pos < offset + len) {
> >
> >         if (i >=3D nfrags) {
> >
> >                 BUG_ON(skb_headlen(list_skb));    (skbuff.c:3120)
> >
> >                 =E2=80=A6
> >
> >         }
> >
> >         =E2=80=A6
> >
> > }
> >
> > A skb that has no frags but frag_list also causes BUG_ON().
> >
> > I wonder if skb like follows is legal? Could skb in frag_list have
> > linear data region?

The answer is : skb_segment() is very complex but does not handle all
possible cases.

skb found in skb_shinfo(skb)->frag_list must not have anything in their
skb->head. This would require very expensive logic and memory
allocations and copies.

Make sure you follow this rule in your driver, or even better leave thi=
s
work to GRO engine.
