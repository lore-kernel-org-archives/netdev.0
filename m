From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] ipv4: Early TCP socket demux.
Date: Thu, 21 Jun 2012 00:10:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1206202305070.1971@ja.ssi.bg>
References: <20120619.214957.1282277480138040899.davem@davemloft.net> <alpine.LFD.2.00.1206200937040.1912@ja.ssi.bg> <20120620.005753.545788933895952782.davem@davemloft.net> <20120620.023002.243497856926894946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:60025 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755054Ab2FTVFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 17:05:17 -0400
In-Reply-To: <20120620.023002.243497856926894946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 20 Jun 2012, David Miller wrote:

> > Date: Wed, 20 Jun 2012 10:00:37 +0300 (EEST)
> > 
> >> 			if (skb->dev != dst->dev)
> >> 				dst = NULL;
> > 
> > That makes the most sense.
> 
> Doesn't work, dst->dev is &net->loopback_dev for these locally
> destined input routes.

	I see, correct.

> We have to instead check rt->rt_iif or similar.

	Yes, rt_iif should be valid for packets with
skb->dst = NULL. It is incorrect only on loopback
traffic diverted to "lo", i.e. when skb->dst != NULL.
But it concerns UDP which is not handled by GRO yet.

	When UDP support for GRO is implemented
dev_gro_receive() should additionally check skb_dst
to ignore local copy of b-m/cast traffic sent via
ip_mc_output -> ip_dev_loopback_xmit because
in this case dst->dev and skb->dst can be eth0
where NETIF_F_GRO can be set.

Regards

--
Julian Anastasov <ja@ssi.bg>
