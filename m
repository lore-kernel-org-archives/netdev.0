From: Joby Poriyath <joby.poriyath@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: allocate xenvif arrays using
 vzalloc.
Date: Tue, 29 Oct 2013 18:46:47 +0000
Message-ID: <20131029184647.GA3261@citrix.com>
References: <20131029152628.GA3065@citrix.com>
 <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<andrew.bennieston@citrix.com>, <david.vrabel@citrix.com>,
	<malcolm.crossley@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46801 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab3J2SrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 14:47:15 -0400
Content-Disposition: inline
In-Reply-To: <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 08:43:50AM -0700, Eric Dumazet wrote:
> On Tue, 2013-10-29 at 15:27 +0000, Joby Poriyath wrote:
> > This will reduce memory pressure when allocating struct xenvif.
> > 
> > The size of xenvif struct has increased from 168 to 36632 bytes (on x86-32).
> > See commit b3f980bd827e6e81a050c518d60ed7811a83061d. This resulted in
> > occasional netdev allocation failure in dom0 with 752MiB RAM, due to
> > fragmented memory.
> 
> This looks overkill. 
> 
> Replacing a single allocation of ~36 KB into 5 vmalloc() looks like you
> did not really tried other things...
> 
> This should be done generically in alloc_netdev_mqs()

Sorry Eric, I didn't quite understand how this can be generically done.

The netback interfaces are tied to the Xen guests (VMs) and these are created 
when guests are started and deleted when guest are halted.

> 
> Take a look at commit 60877a32bce00041
> ("net: allow large number of tx queues")
> 

I could try allocating using kmalloc and if that fails, then fall back
to vmalloc.

Thanks,
Joby
