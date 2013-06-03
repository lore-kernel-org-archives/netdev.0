From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next] netlink: allow large data transfers from
 user-space
Date: Mon, 03 Jun 2013 10:12:39 -0700
Message-ID: <1370279559.24311.160.camel@edumazet-glaptop>
References: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33095 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab3FCRMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 13:12:40 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so974649pab.22
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 10:12:40 -0700 (PDT)
In-Reply-To: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 18:39 +0200, Pablo Neira Ayuso wrote:

> +	if (is_vmalloc_addr(skb->head)) {
> +		vfree(skb->head);
> +		skb->data = NULL;
> +	}
>  

You probably meant :

	skb->head = NULL;

Now, cross our fingers we do not skb_orphan() these skb too early :)
