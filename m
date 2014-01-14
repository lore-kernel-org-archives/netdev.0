From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/3] bonding: fix bond_3ad RCU usage
Date: Mon, 13 Jan 2014 22:22:52 -0800 (PST)
Message-ID: <20140113.222252.1955015452268147519.davem@davemloft.net>
References: <1389351585-19615-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaANGW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:22:56 -0500
In-Reply-To: <1389351585-19615-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Fri, 10 Jan 2014 11:59:42 +0100

> While digging through bond_3ad.c I've found that the RCU usage there is
> just wrong - it's used as a kind of mutex/spinlock instead of RCU.
> 
> v3->v4: remove useless goto and wrap __get_first_agg() in proper RCU.
> 
> v2->v3: make bond_3ad_set_carrier() use RCU read lock for the whole
> function, so that all other functions will be protected by RCU as well.
> This way we can use _rcu variants everywhere.
> 
> v1->v2: use generic primitives instead of _rcu ones cause we can hold RTNL
> lock without RCU one, which is still safe.
> 
> This patchset is on top of bond_3ad.c cleanup:
> http://www.spinics.net/lists/netdev/msg265447.html

Series applied, thank you.
