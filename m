From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 15:11:31 +0200
Message-ID: <49E72E83.50702@trash.net>
References: <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulmck@linux.vnet.ibm.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56048 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbZDPNLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 09:11:36 -0400
In-Reply-To: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds wrote:
> On Wed, 15 Apr 2009, Stephen Hemminger wrote:
>> The counters are the bigger problem, otherwise we could just free table
>> info via rcu.  Do we really have to support: replace where the counter
>> values coming out to user space are always exactly accurate, or is it
>> allowed to replace a rule and maybe lose some counter ticks (worst case
>> NCPU-1).
> 
> Why not just read the counters fromt he old one at RCU free time (they are 
> guaranteed to be stable at that point, since we're all done with those 
> entries), and apply them at that point to the current setup?

We need the counters immediately to copy them to userspace, so waiting
for an asynchronous RCU free is not going to work.
