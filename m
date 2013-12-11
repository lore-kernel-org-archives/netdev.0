From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv4: fix wildcard search with
 inet_confirm_addr()
Date: Wed, 11 Dec 2013 14:49:10 -0500 (EST)
Message-ID: <20131211.144910.1065298780981411778.davem@davemloft.net>
References: <alpine.LFD.2.03.1311132244001.1712@ssi.bg>
	<1386684160-4394-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab3LKTtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:49:19 -0500
In-Reply-To: <1386684160-4394-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 10 Dec 2013 15:02:40 +0100

> 39a6d0630012 ("[NETNS]: Process inet_confirm_addr in the
> correct namespace."), the code supposes that it will never be NULL. This
> function is never called with in_dev == NULL, but it's exported and may be used
> by an external module.
> 
> Because this patch restore the ability to call inet_confirm_addr() with in_dev
> == NULL, I partially revert the above commit, as suggested by Julian.
> 
> CC: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

I personally think that we may be over analyzing this, because if some
external module actually cared, someone would have complained in the
last _5_ years as that's how long the new semantics have been in
place.

Nevertheless, passing in the network namespace explicitly is a bit
nicer than having special behavior for RT_SCOPE_LINE, thus I've
applied this.

Thanks.
