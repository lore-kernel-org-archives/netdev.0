From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch for 2.6.27? 2/2] drivers/net/netxen/netxen_nic_hw.c: fix
 printk warnings
Date: Thu, 31 Jul 2008 23:28:09 -0700
Message-ID: <20080731232809.470dd7d1.akpm@linux-foundation.org>
References: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
	<20080801061952.GI27241@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59087 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752325AbYHAGaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 02:30:18 -0400
In-Reply-To: <20080801061952.GI27241@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1 Aug 2008 16:19:53 +1000 Simon Horman <horms@verge.net.au> wrote:

> On Wed, Jul 30, 2008 at 12:50:12PM -0700, akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_read_direct':
> > drivers/net/netxen/netxen_nic_hw.c:1414: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
> > drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_write_direct':
> > drivers/net/netxen/netxen_nic_hw.c:1487: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
> > 
> > You don't know what type was used for u64 hence they cannot be printed without
> > casting.
> 
> Good grief, that is a sledgehammer to crack an egg.
> Pity it is the only tool available :-(

The sad thing is that if/when we get around to converting all 64-bit
architectures to `long long', we then get to delete all these casts.

Oh well, at least they're easy to grep for.

I wonder who was the first 64-bit bright spark who decided to use `long'.
