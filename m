From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 12:17:00 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904131213360.26713@localhost.localdomain>
References: <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com> <20090412.181330.23529546.davem@davemloft.net> <20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam>
 <Pine.LNX.4.62.0904132102030.10428@wlug.westbo.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Martin Josefsson <gandalf@mjufs.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59069 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751522AbZDMT1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 15:27:51 -0400
In-Reply-To: <Pine.LNX.4.62.0904132102030.10428@wlug.westbo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 13 Apr 2009, Martin Josefsson wrote:
> 
> Doesn't spin_lock() result in a pipeline flush on x86?

It's about 20-40 cycles when cached and uncontended, with some outliers 
(50+ cycles on P4, 12 cycles on some AMD opterons).

So it's not a big deal if you actually hit that case.

> iirc there was a benchmark in an RCU paper that tested using per cpu
> spin_locks and the result was that it didn't scale well at all.

Spinlocks scale wonderfully well if you only touch them on one CPU.

Of course, if you truly only touch them on one CPU they are pointless, but 
a "all normal code only touches the local CPU spinlock, the really odd 
cases take all locks" approach works fine. It makes the uncommon case 
really quite slow, but if it truly is uncommon, that's fine.

			Linus
