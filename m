From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] ipv6: implement dataplane support for rthdr type 4
 (Segment Routing Header)
Date: Mon, 17 Oct 2016 10:57:06 -0400 (EDT)
Message-ID: <20161017.105706.175400937082419121.davem@davemloft.net>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
        <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933143AbcJQO5L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:57:11 -0400
In-Reply-To: <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Mon, 17 Oct 2016 16:42:22 +0200

> +/*
> + * SRH
> + */
> +struct ipv6_sr_hdr {
> +	__u8	nexthdr;
> +	__u8	hdrlen;
> +	__u8	type;
> +	__u8	segments_left;
> +	__u8	first_segment;
> +	__be16	flags;
> +	__u8	reserved;
> +
> +	struct in6_addr segments[0];
> +} __attribute__((packed));

Please don't use packed, it results in extremely inefficient code on
several architectures.

You can simply declare the flags as two 8-bit pieces and all will work
out fine.
