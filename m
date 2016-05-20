From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx5: avoid unused variable warning
Date: Fri, 20 May 2016 11:24:21 -0700 (PDT)
Message-ID: <20160520.112421.2148726893293404256.davem@davemloft.net>
References: <1463581293-1069553-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, john.r.fastabend@intel.com, amirva@mellanox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbcETSYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 14:24:22 -0400
In-Reply-To: <1463581293-1069553-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 May 2016 16:21:07 +0200

> When CONFIG_NET_CLS_ACT is disabled, we get a new warning in the mlx5
> ethernet driver because the tc_for_each_action() loop never references
> the iterator:
> 
> mellanox/mlx5/core/en_tc.c: In function 'mlx5e_stats_flower':
> mellanox/mlx5/core/en_tc.c:431:20: error: unused variable 'a' [-Werror=unused-variable]
>   struct tc_action *a;
> 
> This changes the dummy tc_for_each_action() macro by adding a
> cast to void, letting the compiler know that the variable is
> intentionally declared but not used here. I could not come up
> with a nicer workaround, but this seems to do the trick.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: aad7e08d39bd ("net/mlx5e: Hardware offloaded flower filter statistics support")
> Fixes: 00175aec941e ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")

Applied, thanks Arnd.
