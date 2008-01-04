From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] LSM: Add inet_sys_snd_skb() LSM hook
Date: Thu, 03 Jan 2008 20:45:49 -0800 (PST)
Message-ID: <20080103.204549.204229388.davem@davemloft.net>
References: <20080103171649.14445.65274.stgit@flek.americas.hpqcorp.net>
	<20080103172539.14445.1668.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753724AbYADEpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 23:45:50 -0500
In-Reply-To: <20080103172539.14445.1668.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 03 Jan 2008 12:25:39 -0500

> Add an inet_sys_snd_skb() LSM hook to allow the LSM to provide packet level
> access control for all outbound packets.  Using the existing postroute_last
> netfilter hook turns out to be problematic as it is can be invoked multiple
> times for a single packet, e.g. individual IPsec transforms, adding unwanted
> overhead and complicating the security policy.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

I disagree with this change.

The packet is different each time you see it in the postrouting hook,
and also the new hook is thus redundant.

If it's a performance issue and you can classify the security early,
mark the SKB as "seen" and then on subsequent hooks you can just
return immediately if that flag is set.
