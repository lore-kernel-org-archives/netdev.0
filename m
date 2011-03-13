From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer: Don't disable BH for initial fast RCU lookup.
Date: Sun, 13 Mar 2011 16:42:15 -0700 (PDT)
Message-ID: <20110313.164215.193721466.davem@davemloft.net>
References: <20110308.145954.59682618.davem@davemloft.net>
	<1300010649.2761.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756321Ab1CMXlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 19:41:37 -0400
In-Reply-To: <1300010649.2761.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 13 Mar 2011 11:04:09 +0100

> David, I am not sure this is safe, since we use call_rcu_bh() when
> freeing one item. One cpu could decide to kfree() one item while another
> cpu could still use it.
> 
> rcu_read_lock_bh() was signalling to others cpu we were in a softirq
> section, so we were delaying a possible kfree().

Ok, could we use normal call_rcu() to solve this then?
