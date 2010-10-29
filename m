From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCH] decnet: RCU conversion and get rid of dev_base_lock
Date: Fri, 29 Oct 2010 14:54:39 +0100
Message-ID: <1288360479.9016.35.camel@dolmen>
References: <1288357764.2560.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.painless.aaisp.net.uk ([81.187.30.52]:39647 "EHLO
	b.painless.aaisp.net.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932652Ab0J2OZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 10:25:31 -0400
In-Reply-To: <1288357764.2560.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2010-10-29 at 15:09 +0200, Eric Dumazet wrote:
> While tracking dev_base_lock users, I found decnet used it in
> dnet_select_source(), but for a wrong purpose:
> 
> Writers only hold RTNL, not dev_base_lock, so readers must use RCU if
> they cannot use RTNL.
> 
> Adds an rcu_head in struct dn_ifaddr and handle proper RCU management.
> 
> Adds __rcu annotation in dn_route as well.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I've not tested this, but I've read through it all and it seems good to
me.

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.


