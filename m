From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] libcxgbi/cxgb4i : Fix ipv6 build failure
 caught with randconfig
Date: Tue, 12 Aug 2014 15:22:15 -0700 (PDT)
Message-ID: <20140812.152215.2300902059999669762.davem@davemloft.net>
References: <1407880481-22352-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, jim.epost@gmail.com, sfr@canb.auug.org.au
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbaHLWWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:22:17 -0400
In-Reply-To: <1407880481-22352-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 12 Aug 2014 14:54:41 -0700

> Previous guard of IS_ENABLED(CONFIG_IPV6) is not sufficient when cxgbi drivers
> are built into kernel but ipv6 is not. Change guard to only enable when either
> ipv6 is built-in or both are modules.
> 
> Fixes: e81fbf6cd652 ("libcxgbi:cxgb4i Guard ipv6 code with a config check")
> Fixes: fc8d0590d914 ("libcxgbi: Add ipv6 api to driver")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

That's not how you fix problems like this.

Instead, you should use Kconfig conditions to make sure your driver is
enabled in a manner which is compatible with what IPV6 has been set to.

No user should have to know about these strange dependencies just to get
IPV6 enabled in your driver.

Really, your change makes IPV6 get disabled if IPV6 is modular and your
driver is built statically.  I do not think any user would consider that
reasonable behavior.
