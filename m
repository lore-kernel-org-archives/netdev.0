From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 09:50:49 +0100
Message-ID: <20100115095049.14190a50@marrow.netinsight.se>
References: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com>
	<20100115.003636.199394610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:22764 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932094Ab0AOIuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 03:50:55 -0500
In-Reply-To: <20100115.003636.199394610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jan 2010 00:36:36 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> > Remove inline skb data in tcp_sendmsg(). For the few devices that
> > don't support NETIF_F_SG, dev_queue_xmit will call skb_linearize,
> > and pass the penalty to those slow devices (the following drivers
> > do not support NETIF_F_SG: 8139cp.c, amd8111e.c, dl2k.c, dm9000.c,
> > dnet.c, ethoc.c, ibmveth.c, ioc3-eth.c, macb.c, ps3_gelic_net.c,
> > r8169.c, rionet.c, spider_net.c, tsi108_eth.c, veth.c,
> > via-velocity.c, atlx/atl2.c, bonding/bond_main.c, can/dev.c,
> > cris/eth_v10.c).
> 
> I was really surprised to see r8169.c in that list.
> 
> It even has all the code in it's ->ndo_start_xmit() method
> to build fragments properly and handle segmented SKBs, it
> simply doesn't set NETIF_F_SG in dev->features for whatever
> reason.

The same thing goes for via-velocity.c, it's turned on via ethtool
though (ethtool_op_set_sg).

// Simon
