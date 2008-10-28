From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: don't use INIT_RCU_HEAD
Date: Tue, 28 Oct 2008 13:25:21 -0700 (PDT)
Message-ID: <20081028.132521.120536910.davem@davemloft.net>
References: <20081028133124.GA3006@x200.localdomain>
	<20081028161017.GF6779@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56911
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752903AbYJ1UZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:25:44 -0400
In-Reply-To: <20081028161017.GF6779@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 28 Oct 2008 09:10:17 -0700

> On Tue, Oct 28, 2008 at 04:31:24PM +0300, Alexey Dobriyan wrote:
> > call_rcu() will unconditionally rewrite RCU head anyway.
> > Applies to 
> > 	struct neigh_parms
> > 	struct neigh_table
> > 	struct net
> > 	struct cipso_v4_doi
> > 	struct in_ifaddr
> > 	struct in_device
> > 	rt->u.dst
> 
> Assuming that no code outside of RCU is testing the rcu_head fields...
> That would usually be a bad idea in any case, as call_rcu() makes no
> guarantee about the values of these fields after the callback is invoked.
> Furthermore, there have been serious proposals that would change the
> call_rcu() field names and layout.
> 
> Therefore:
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

I've applied this patch, thanks everyone.
