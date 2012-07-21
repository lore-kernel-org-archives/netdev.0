From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4: tcp: remove per net tcp_sock
Date: Sat, 21 Jul 2012 17:00:35 +0900
Message-ID: <20120721170035.be1bb3aff663ecf9e81028e2@gmail.com>
References: <1342719243.2626.4571.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com,
	wsommerfeld@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59921 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab2GUIAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 04:00:39 -0400
Received: by pbbrp8 with SMTP id rp8so7502135pbb.19
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2012 01:00:38 -0700 (PDT)
In-Reply-To: <1342719243.2626.4571.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jul 2012 19:34:03 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
> +	.sk = {
> +		.__sk_common = {
> +			.skc_refcnt = ATOMIC_INIT(1),
> +		},
> +		.sk_wmem_alloc	= ATOMIC_INIT(1),
> +		.sk_allocation	= GFP_ATOMIC,
> +		.sk_flags	= (1UL << SOCK_USE_WRITE_QUEUE),
> +	},
> +	.pmtudisc = IP_PMTUDISC_WANT,
> +};

RST packet generated from unicast_sock have 0 TTL value.
I think ".uc_ttl = -1" is needed in above initialization.
