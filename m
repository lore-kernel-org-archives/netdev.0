From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sock_copy() fixes
Date: Thu, 16 Jul 2009 18:09:55 -0700 (PDT)
Message-ID: <20090716.180955.105341181.davem@davemloft.net>
References: <4A5DF5B4.5090809@trash.net>
	<4A5E33D9.2030602@gmail.com>
	<4A5EEF26.5040209@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933893AbZGQBJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:09:51 -0400
In-Reply-To: <4A5EEF26.5040209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jul 2009 11:13:10 +0200

> [PATCH] net: sock_copy() fixes
> 
> Commit e912b1142be8f1e2c71c71001dc992c6e5eb2ec1
> (net: sk_prot_alloc() should not blindly overwrite memory)
> took care of not zeroing whole new socket at allocation time.
> 
> sock_copy() is another spot where we should be very careful.
> We should not set refcnt to a non null value, until
> we are sure other fields are correctly setup, or
> a lockless reader could catch this socket by mistake,
> while not fully (re)initialized.
> 
> This patch puts sk_node & sk_refcnt to the very beginning
> of struct sock to ease sock_copy() & sk_prot_alloc() job.
> 
> We add appropriate smp_wmb() before sk_refcnt initializations
> to match our RCU requirements (changes to sock keys should
> be committed to memory before sk_refcnt setting)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued for -stable, thanks!
