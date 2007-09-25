From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 4/7] CAN: Add broadcast manager (bcm) protocol
Date: Tue, 25 Sep 2007 09:51:22 -0300
Message-ID: <20070925125122.GD18348@ghostprotocols.net>
References: <20070925122029.15989.0@janus.isnogud.escape.de> <20070925122243.15989.4@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:65452 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbXIYMvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 08:51:32 -0400
Received: by an-out-0708.google.com with SMTP id d31so279868and
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 05:51:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070925122243.15989.4@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Sep 25, 2007 at 02:20:33PM +0200, Urs Thuermann escreveu:
> This patch adds the CAN broadcast manager (bcm) protocol.
> 
> +static void bcm_can_tx(struct bcm_op *op)
> +{
> +	skb = alloc_skb(CFSIZ,
> +			in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);

We have gfp_any() for this:

[acme@filo net-2.6.24]$ grep gfp_any net/*/*.[ch]
net/ipv4/tcp.c:         tcp_send_active_reset(sk, gfp_any());
net/ipv6/route.c:       skb = nlmsg_new(rt6_nlmsg_size(), gfp_any());
net/ipv6/route.c:       err = rtnl_notify(skb, pid, RTNLGRP_IPV6_ROUTE,
nlh, gfp_any());
net/netfilter/nfnetlink.c:      netlink_broadcast(nfnl, skb, pid, group,
gfp_any());
net/netlink/af_netlink.c:       skb = netlink_trim(skb, gfp_any());

[acme@filo net-2.6.24]$ grep in_interrupt net/*/*.[ch]
net/decnet/dn_route.c:  int user_mode = !in_interrupt();
net/decnet/dn_table.c:  if (in_interrupt() && net_ratelimit()) {
[acme@filo net-2.6.24]$

> +static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
> +			     struct can_frame *frames, int has_timestamp)
> +{
> +	struct sk_buff *skb;
> +	struct can_frame *firstframe;
> +	struct sockaddr_can *addr;
> +	struct sock *sk = op->sk;
> +	int datalen = head->nframes * CFSIZ;
> +	int err;
> +
> +	skb = alloc_skb(sizeof(*head) + datalen,
> +			in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);

ditto

