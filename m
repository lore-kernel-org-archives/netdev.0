From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 17:02:57 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904151659360.4042@localhost.localdomain>
References: <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, shemminger@vyatta.com, kaber@trash.net,
	jeff.chua.linux@gmail.com, paulmck@linux.vnet.ibm.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090415.164811.19905145.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Apr 2009, David Miller wrote:
> 
> I really think we should entertain the idea where we don't RCU quiesce
> when adding rules.  That was dismissed as not workable because the new
> rule must be "visible" as soon as we return to userspace but let's get
> real, effectively it will be.

I never understood that dismissal.

The new rule _will_ be visible as we return to user space. It's just that 
old packets may still be in flight in other queues.

But that is true even _without_ the "synchronize_net()". The old packets 
just had to make it slightly further in the queueing - but as far as user 
space is concerned, there is absolutely _zero_ difference between the two. 
In both cases it may see packets queued with the old rules. 

> I almost cringed when the per-spinlock idea was proposed, but per-cpu
> rwlocks just takes things too far for my tastes.

I really personally would prefer the RCU approach too. I don't think 
rwlocks are any more cringe-worthy than spinlocks, although it is true 
that they tend to be slightly more expensive.

The pure RCU "just get rid of the unnecessary 'serialze_net()'" approach 
seems to be clearly superior to either.

		Linus
