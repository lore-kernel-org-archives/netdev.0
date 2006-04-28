From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC PATCH] [IPV6]: Fix race in route selection.
Date: Fri, 28 Apr 2006 15:58:27 -0700 (PDT)
Message-ID: <20060428.155827.04891779.davem@davemloft.net>
References: <20060428.020456.35552581.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4227
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932082AbWD1W6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:58:20 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060428.020456.35552581.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 28 Apr 2006 02:04:56 +0900 (JST)

> We eliminated rt6_dflt_lock (to protect default router pointer)
> at 2.6.17-rc1, and introduced rt6_select() for general router selection.
> The function is called in the context of rt6_lock read-lock held,
> but this means, we have some race conditions when we do round-robin.
> 
> Am I correct?
> 
> If so, we should put some spin_lock for serialization.
> 
> Comments?
> 
> Signed-off-by; YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Or, should we run whole part of rt6_select() under some lock?

I think the local lock will work and it is fine for now.
I will apply this as-is to fix the bug.

But in the longer term this seems a little bit heavy operation.
Perhaps there is some way to use "xchg()" here?  It is just moving a
pointer around for a round robin list, if it could be reduced to just
a single pointer store, we could even do it without atomic operations.

