From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ip: Fix ip_dev_loopback_xmit()
Date: Fri, 16 Apr 2010 08:03:59 +0800
Message-ID: <w2o412e6f7f1004151703xdcc4da16s4eb6308f2578b531@mail.gmail.com>
References: <1271101251.16881.135.camel@edumazet-laptop> <1271337401.16881.2563.camel@edumazet-laptop>
	<1271358783.16881.2949.camel@edumazet-laptop> <20100415.142641.125242830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, eparis@redhat.com, netdev@vger.kernel.org,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:45641 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758042Ab0DPAEU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 20:04:20 -0400
Received: by gxk9 with SMTP id 9so1149082gxk.8
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 17:04:19 -0700 (PDT)
In-Reply-To: <20100415.142641.125242830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 5:26 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 15 Apr 2010 21:13:03 +0200
>
>> [PATCH] ip: Fix ip_dev_loopback_xmit()
>
> Applied to net-2.6, thanks Eric.


Now, I am doubting the correctness of  the following comment:

/*
 * The higher levels take care of making this non-reentrant (it's
 * called with bh's disabled).
 */
static netdev_tx_t loopback_xmit(struct sk_buff *skb,
                                 struct net_device *dev)
{
        struct pcpu_lstats __percpu *pcpu_lstats;
        struct pcpu_lstats *lb_stats;
        int len;

        skb_orphan(skb);

        skb->protocol =3D eth_type_trans(skb, dev);

And these lines:

        /* it's OK to use per_cpu_ptr() because BHs are off */
        pcpu_lstats =3D (void __percpu __force *)dev->ml_priv;
        lb_stats =3D this_cpu_ptr(pcpu_lstats);

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
