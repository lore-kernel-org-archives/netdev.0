From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v13)
Date: Wed, 22 Apr 2009 08:32:08 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904220821240.3101@localhost.localdomain>
References: <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com>
 <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421193924.GA24404@elte.hu> <20090421143927.52d7d89d@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090421143927.52d7d89d@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 21 Apr 2009, Stephen Hemminger wrote:
>
> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> recursive lock that can be nested.

Ack on the code.

But the comment is _still_ crap. Please update. It's not a recursive lock, 
as clearly shown by the code itself. It's a per-cpu read-write lock, and 
only the reader is "recursive" (but that's how read-write locks with in 
Linux, and that has nothing to do with anything).

So make the explanations match the code and the intent. Write it something 
like

	This version of x_tables (ip/ip6/arp) locking uses a per-cpu
	reader-writer lock lock where the readers can nest.

and don't confuse it with incorrect commit messages. The lock is very much 
not recursive - on purpose - for half the people taking it.

[ That, btw, was always true, even in the original random open-coded 
  version. Because you can't actually do a real recursive lock without 
  having notion of "current ownership" either by making the count be 
  <per-thread,per-lock> - like the BKL - or by saving the ownership 
  information in the lock. A plain counter simply doesn't do it. ]

		Linus
