From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 12:18:41 -0600
Message-ID: <20080919181840.GE30956@parisc-linux.org>
References: <20080918.193815.175549834.davem@davemloft.net> <41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Arjan van de Ven <arjan@infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:36479 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbYISSS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 14:18:57 -0400
Content-Disposition: inline
In-Reply-To: <41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 7:38 PM, David Miller wrote:
> During kernel summit I was speaking with Arjan van de Ven
> about irqbalanced and networking card multiqueue interrupts.
> 
> In order for irqbalanaced to make smart decisions, what needs to
> happen in drivers is that the individual interrupts need to be
> named in such a way that he can tell by looking at /proc/interrupts
> output that these interrupts are related.
> 
> So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> have names like:
> 
>        eth0-rx-0
>        eth0-rx-1
>        eth0-tx-0
>        eth0-tx-1
> 
> So let's make an effort to get this done right in 2.6.28 and meanwhile
> Arjan can add the irqbalanced code.

Instead of having magic names, how about we put something in
/proc/irq/nnn/ that lets us tell which interrupts are connected to which
queues?

Another idea I've been thinking about is a flag to tell irqbalance to
leave stuff alone, and we just set stuff up right the first time.

We were discussing various options around multiqueue at first the scsi
multiqueue BOF and later at the PCI MSI BOF.  There's a general feeling
that drivers should be given some guidance about how many queues they
should be enabling, and the sysadmin needs to be the one telling the
PCI layer, which drivers should then query.  The use cases vary wildly
depending whether you're doing routing or are an end node, whether
you're doing v12n or NUMA or both and on just how many cards and cpus
you have.

In a storage / NUMA configuration we really want to set up one queue per
cpu / package / node (depending on resource constraints) and know that
the interrupt is going to come back to the same cpu / package / node.
We definitely don't want irqbalanced moving the interrupt around.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
