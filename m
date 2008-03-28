From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/6][NETNS][SOCK]: Introduce per-net inuse
 counters.
Date: Thu, 27 Mar 2008 17:38:23 -0700 (PDT)
Message-ID: <20080327.173823.107235292.davem@davemloft.net>
References: <47EB550B.8070401@openvz.org>
	<47EB5711.8040705@openvz.org>
	<47EC01AE.9010402@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50265
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753205AbYC1AiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:38:23 -0400
In-Reply-To: <47EC01AE.9010402@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 27 Mar 2008 21:21:02 +0100

> Given that :
> 
> 1) pcounter should really go away from kernel, since Andrew disagree 
> with the implementation.
> 
> 2) the need to enumerate all protocols in your enum, it seems ... ugly :)
> 
> 3) alloc_percpu(struct net_prot_inuse) per net is nice because we dont 
> waste memory (if we had to use percpu_counters for each proto for example)
> 
> I suggest to :
> 
> 1) not use pcounter anymore
> 
> 2) change 'inuse' field to 'inuse_idx' or 'prot_num' that is 
> automatically allocated at proto_register time, instead statically at 
> compile time.
> 
> Just provide a big enough NET_INUSE_NR (might depend on IPV6 present or 
> not, static or module) to take into account all possible protocols.
> 
> struct net_prot_inuse {
> 	int val[NET_INUSE_NR];
> };

I agree mostly, and I'll thus hold off on these patches
until the details are hashed out.
