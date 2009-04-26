From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-CPU recursive lock {XV}
Date: Sun, 26 Apr 2009 14:57:46 -0700
Message-ID: <20090426145746.1184aeba@nehalam>
References: <20090421111541.228e977a@nehalam>
	<20090421193924.GA24404@elte.hu>
	<20090421143927.52d7d89d@nehalam>
	<alpine.LFD.2.00.0904220821240.3101@localhost.localdomain>
	<20090423210938.1501507b@nehalam>
	<49F146FF.5050200@cosmosbay.com>
	<20090424091839.6e13ebec@nehalam>
	<49F22465.80305@gmail.com>
	<20090425133052.4cb711f5@nehalam>
	<49F4A6E3.7080102@cosmosbay.com>
	<20090426185646.GB29238@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754521AbZDZV6R@vger.kernel.org>
In-Reply-To: <20090426185646.GB29238@Krystal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 26 Apr 2009 14:56:46 -0400
Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> * Eric Dumazet (dada1@cosmosbay.com) wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > > Epilogue due to master Jarek. Lockdep carest not about the locking
> > > doth bestowed. Therefore no keys are needed.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > So far, so good, should be ready for inclusion now, nobody complained :)
> > 
> > I include the final patch, merge of your last two patches.
> > 
> > David, could you please review it once again and apply it if it's OK ?
> 
> > Thanks to all for your help and patience
> > 
> > [PATCH] netfilter: use per-CPU recursive lock {XV}
> 
> Hi Eric, 
> 
> Suitable name would probably be :
> 

But Linus is trying to delude himself.

This usage is recursive even if he doesn't like the terminology.
The same CPU has to be able to reacquire the read lock without deadlocking.
If reader/writer locks were implemented in a pure writer gets priority
method, then this code would break!  So yes read locks can be used recursively
now in Linux, but if the were implemented differently then this code
would break.  For example, the -rt kernel turns all read/write locks into
mutexs, so the -rt kernel developers will have to address this.
