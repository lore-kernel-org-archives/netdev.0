From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netlink: allow large data transfers from
 user-space
Date: Mon, 03 Jun 2013 08:25:52 -0700
Message-ID: <1370273152.24311.150.camel@edumazet-glaptop>
References: <1370272203-25062-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34852 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab3FCPZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:25:55 -0400
Received: by mail-pa0-f41.google.com with SMTP id tj12so683940pac.0
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:25:54 -0700 (PDT)
In-Reply-To: <1370272203-25062-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 17:10 +0200, Pablo Neira Ayuso wrote:

> +	if (size <= PAGE_SIZE)
> +		return alloc_skb(size, GFP_KERNEL);
> +

That would be

 	if (size < SKB_WITH_OVERHEAD(PAGE_SIZE))

or

	if (size < SKB_MAX_HEAD(0))
