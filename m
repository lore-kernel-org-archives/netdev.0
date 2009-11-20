From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 23:21:08 +0100
Message-ID: <4B071654.6040300@gmail.com>
References: <20091120133245.GA9038@ff.dom.local> <4B06AB96.8040805@gmail.com> <20091120200434.GB2688@ami.dom.local> <4B070D9B.60409@gmail.com> <20091120220851.GA4717@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35251 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbZKTWVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:21:10 -0500
In-Reply-To: <20091120220851.GA4717@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Fri, Nov 20, 2009 at 10:43:55PM +0100, Eric Dumazet wrote:
>>> Hmm... Actually, why did I have to do lockdep's job...
>> In fact I could not find why irq masking is necessary, and lockdep i=
s
>> fine with my code and my testings. Care to explain what problem you =
spotted ?
>>
>=20
> CPU1						 CPU2
> net_rx_action()					 net_rx_action()
>  xps_flush()				  	  xps_flush()
>   q =3D &per_cpu(xps_pcpu_queue, cpu2)		   q =3D &per_cpu(xps_pcpu_qu=
eue, cpu1)
>   spin_lock(&q->list.lock of cpu2)		   spin_lock(&q->list.lock of cpu=
1)
>=20
> <IPI>						 <IPI>
> remote_free_skb_list()				 remote_free_skb_list()
> waiting on spin_lock(&q->list.lock of cpu1)	 waiting on spin_lock(&q-=
>list.lock of cpu2)
>=20
>=20
> IPIs triggerered e.g. by CPU3 (or/and CPU4...) doing net_rx_action as=
 well.
>=20

:) Now I am convinced :)

Thanks jarek


