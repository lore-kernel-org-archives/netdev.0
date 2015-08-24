From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Fix RCU splat in af_key
Date: Mon, 24 Aug 2015 14:49:35 -0700 (PDT)
Message-ID: <20150824.144935.2073501948858391876.davem@davemloft.net>
References: <1440451037-18564-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbHXVti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 17:49:38 -0400
In-Reply-To: <1440451037-18564-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 24 Aug 2015 15:17:17 -0600

> Hit the following splat testing VRF change for ipsec:
 ...
> In pfkey_sendmsg the net mutex is taken and then pfkey_broadcast takes
> the RCU lock.
> 
> Since pfkey_broadcast takes the RCU lock the allocation argument is
> pointless since GFP_ATOMIC must be used between the rcu_read_{,un}lock.
> The one call outside of rcu can be done with GFP_KERNEL.
> 
> Fixes: 7f6b9dbd5afbd ("af_key: locking change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - removed allocation arg and hardcoded to GFP_ATOMIC during rcu locking

Applied, thanks David.
