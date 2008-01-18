From: David Miller <davem@davemloft.net>
Subject: Re: [FIB]: Fix rcu_dereference() abuses in fib_trie.c
Date: Fri, 18 Jan 2008 03:31:53 -0800 (PST)
Message-ID: <20080118.033153.235763392.davem@davemloft.net>
References: <20080115092940.311fb2c3.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen.hemminger@vyatta.com,
	herbert@gondor.apana.org.au
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753403AbYARLbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 06:31:53 -0500
In-Reply-To: <20080115092940.311fb2c3.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 15 Jan 2008 09:29:40 +0100

> node_parent() and tnode_get_child() currently use rcu_dereference().
> 
> These functions are called from both 
> - readers only paths (where rcu_dereference() is needed), and 
> - writer path (where rcu_dereference() is not needed)
> 
> To make explicit where rcu_dereference() is really needed, I introduced
> new node_parent_rcu() and tnode_get_child_rcu() functions which use
> rcu_dereference(), while node_parent() and tnode_get_child() dont use it.
> 
> Then I changed calling sites where rcu_dereference() was really needed to
> call the _rcu() variants.
> 
> This should have no impact but for alpha architecture, and may help future
> sparse checks.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, thanks Eric.
