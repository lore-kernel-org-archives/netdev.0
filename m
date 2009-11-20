From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 23:08:51 +0100
Message-ID: <20091120220851.GA4717@ami.dom.local>
References: <20091120133245.GA9038@ff.dom.local>
 <4B06AB96.8040805@gmail.com>
 <20091120200434.GB2688@ami.dom.local>
 <4B070D9B.60409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:56428 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbZKTWJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:09:10 -0500
Received: by bwz27 with SMTP id 27so3801226bwz.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 14:09:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B070D9B.60409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 10:43:55PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Fri, Nov 20, 2009 at 03:45:42PM +0100, Eric Dumazet wrote:
> >> Jarek Poplawski a =E9crit :
> >>> On 20-11-2009 00:46, Eric Dumazet wrote:
> >>> scheduled) IPIs?
> >> Repeat after me :
> >>
> >> lockdep is my friend, lockdep is my friend, lockdep is my friend..=
=2E :)
> >=20
> > Hmm... Actually, why did I have to do lockdep's job...
>=20
> In fact I could not find why irq masking is necessary, and lockdep is
> fine with my code and my testings. Care to explain what problem you s=
potted ?
>=20

CPU1						 CPU2
net_rx_action()					 net_rx_action()
 xps_flush()				  	  xps_flush()
  q =3D &per_cpu(xps_pcpu_queue, cpu2)		   q =3D &per_cpu(xps_pcpu_queu=
e, cpu1)
  spin_lock(&q->list.lock of cpu2)		   spin_lock(&q->list.lock of cpu1)

<IPI>						 <IPI>
remote_free_skb_list()				 remote_free_skb_list()
waiting on spin_lock(&q->list.lock of cpu1)	 waiting on spin_lock(&q->l=
ist.lock of cpu2)


IPIs triggerered e.g. by CPU3 (or/and CPU4...) doing net_rx_action as w=
ell.

Jarek P.
