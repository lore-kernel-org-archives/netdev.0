From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu recursive spinlock  (v6)
Date: Thu, 16 Apr 2009 18:59:07 +0200
Message-ID: <49E763DB.1000706@trash.net>
References: <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net> <20090416144748.GB6924@linux.vnet.ibm.com> <49E75876.10509@cosmosbay.com> <alpine.LFD.2.00.0904160926520.4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, paulmck@linux.vnet.ibm.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904160926520.4042@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> Guys, this whole discussion has just been filled with crazy crap. Can 
> somebody even explain why we care so deeply about some counters for 
> something that we just _deleted_ and that have random values anyway?
> 
> I can see the counters being interesting while a firewall is active, but I 
> sure don't see what's so wonderfully interesting after-the-fact about a 
> counter on something that NO LONGER EXISTS that it has to be somehow 
> "exactly right".

They're copied to userspace after replacing the ruleset, associated with
the rules that are still active after the change and then added to the
current counters in a second operation. The end result is that the
counters are accurate for rules not changed.

> Show of hands, here: tell me a single use that really _requires_ those 
> exact counters of a netfilter rule that got deleted and is no longer 
> active?

People use netfilter for accounting quite a lot. Having dynamic updates
is also not uncommon, so this might actually matter.


