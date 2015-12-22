From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] soreuseport: define reuseport groups
Date: Tue, 22 Dec 2015 16:40:24 -0500 (EST)
Message-ID: <20151222.164024.1894169450945188344.davem@davemloft.net>
References: <1450814710-17850-1-git-send-email-kraigatgoog@gmail.com>
	<1450814710-17850-2-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbbLVVk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:40:26 -0500
In-Reply-To: <1450814710-17850-2-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 22 Dec 2015 15:05:07 -0500

> +	for (i = 0; i < reuse->num_socks; i++) {
> +		if (reuse->socks[i] == sk) {
> +			reuse->socks[i] = reuse->socks[reuse->num_socks - 1];
> +			reuse->num_socks--;
> +			if (reuse->num_socks == 0)
> +				kfree_rcu(reuse, rcu);
> +			break;
> +		}
> +	}

Don't you need to memmove() the entire rest of the array down one slot
when you hit the matching 'sk' in there?  I can't see how it can work
to only move one entry down.
