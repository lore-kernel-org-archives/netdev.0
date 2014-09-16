From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/7] fou: Support for foo-over-udp RX path
Date: Tue, 16 Sep 2014 15:42:42 -0400 (EDT)
Message-ID: <20140916.154242.2033127900890183747.davem@davemloft.net>
References: <1410838224-19777-1-git-send-email-therbert@google.com>
	<1410838224-19777-3-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150AbaIPTmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 15:42:46 -0400
In-Reply-To: <1410838224-19777-3-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 15 Sep 2014 20:30:19 -0700

> +static inline struct fou *fou_from_sock(struct sock *sk)
> +{
> +	return (struct fou *)sk->sk_user_data;
> +}

Void pointers never need explicit casts, please remove it.

> +static int fou_create(struct net *net, struct fou_cfg *cfg,
> +		      struct socket **sockp)
> +{
 ...
> +	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
> +	fou->protocol = cfg->protocol;
> +	fou->port =  cfg->udp_config.local_udp_port;

Hmmm...

> +	u16 port = htons(cfg->udp_config.local_udp_port);
> +	int err = -EINVAL;
> +
> +	spin_lock(&fou_lock);
> +	list_for_each_entry(fou, &fou_list, list) {

Why different endianness for create and destroy?  Please make both
operations use the same endianness for the port.

> +		if (fou->port == port) {
