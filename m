From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] cxgb4: Not need to hold the adap_rcu_lock lock
 when read adap_rcu_list
Date: Mon, 23 Jun 2014 14:50:35 -0700 (PDT)
Message-ID: <20140623.145035.915335524137481573.davem@davemloft.net>
References: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hariprasad@chelsio.com, leedom@chelsio.com, greearb@candelatech.com
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbaFWVug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 17:50:36 -0400
In-Reply-To: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <rongqing.li@windriver.com>
Date: Fri, 20 Jun 2014 17:32:36 +0800

> cxgb4_netdev maybe lead to dead lock, since it uses a spin lock, and be called
> in both thread and softirq context, but not disable BH, the lockdep report is
> below; In fact, cxgb4_netdev only reads adap_rcu_list with RCU protection, so
> not need to hold spin lock again.

I think this change is fine, and correct, but I would like to see some
reviews from the cxgb4 maintainers.
