From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 17:05:39 -0700 (PDT)
Message-ID: <20090415.170539.34899625.davem@davemloft.net>
References: <49E64C91.5020708@cosmosbay.com>
	<20090415.164811.19905145.davem@davemloft.net>
	<20090415170111.6e1ca264@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, kaber@trash.net, jeff.chua.linux@gmail.com,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37276
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753037AbZDPAFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 20:05:48 -0400
In-Reply-To: <20090415170111.6e1ca264@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 15 Apr 2009 17:01:11 -0700

> The counters are the bigger problem, otherwise we could just free table
> info via rcu.  Do we really have to support: replace where the counter
> values coming out to user space are always exactly accurate, or is it
> allowed to replace a rule and maybe lose some counter ticks (worst case
> NCPU-1).

I say this case doesn't matter until someone can prove that it's
any different from the IPTABLES replace operation system call
executing a few microseconds earlier or later.

There really is no difference, and we're making complexity out of
nothing just to ensure something which isn't actually guarenteed right
now.
