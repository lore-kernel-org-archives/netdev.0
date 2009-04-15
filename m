From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 16:48:11 -0700 (PDT)
Message-ID: <20090415.164811.19905145.davem@davemloft.net>
References: <49E5BDF7.8090502@trash.net>
	<20090415135526.2afc4d18@nehalam>
	<49E64C91.5020708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net, jeff.chua.linux@gmail.com,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751669AbZDOXsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 19:48:20 -0400
In-Reply-To: <49E64C91.5020708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 15 Apr 2009 23:07:29 +0200

> Well, it seems original patch was not so bad after all
> 
> http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/023175.html
> 
> So change per-cpu spinlocks to per-cpu rwlocks 
> 
> and use read_lock() in ipt_do_table() to allow recursion...

Grumble, one more barrier to getting rid of rwlocks in the whole
tree. :-/

I really think we should entertain the idea where we don't RCU quiesce
when adding rules.  That was dismissed as not workable because the new
rule must be "visible" as soon as we return to userspace but let's get
real, effectively it will be.

If there are any stale object reference issues, we can use RCU object
destruction to handle that kind of thing.

I almost cringed when the per-spinlock idea was proposed, but per-cpu
rwlocks just takes things too far for my tastes.
