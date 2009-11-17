From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Tue, 17 Nov 2009 22:32:02 +0100
Message-ID: <4B031652.4050403@gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:60948 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbZKQVcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:32:03 -0500
Received: by bwz27 with SMTP id 27so419917bwz.21
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2009 13:32:08 -0800 (PST)
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote, On 11/11/2009 07:53 AM:

> Third version of RPS.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
...
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 addr1, addr2, ports;
> +	struct ipv6hdr *ip6;
> +	struct iphdr *ip;
> +	u32 hash, ihl;
> +	u8 ip_proto;
> +	int cpu;
> +	struct rps_map *map = NULL;
> +
> +	if (dev->rps_num_maps) {
> +		/*
> +		 * Locate the map corresponding to the NAPI queue that
> +		 * the packet was received on.
> +		 */
> +		int index = skb_get_rx_queue(skb);
> +		if (index < 0 || index >= dev->rps_num_maps)

skb_get_rx_queue() returns u16, so 'index < 0' seems wrong here.

Jarek P.
