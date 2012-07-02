From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in
 tcp_ipv6.c
Date: Sun, 01 Jul 2012 20:26:10 -0700 (PDT)
Message-ID: <20120701.202610.12425223200611171.davem@davemloft.net>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab2GBD0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 23:26:13 -0400
In-Reply-To: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon,  2 Jul 2012 11:18:59 +0800

> -	if (opt) {
> -		newnp->opt = ipv6_dup_options(newsk, opt);
> -		if (opt != np->opt)
> -			sock_kfree_s(sk, opt, opt->tot_len);

This is bogus, if we copy the options into a new copy in
ipv6_dup_options() we have to free the old one or else we
leak it.
