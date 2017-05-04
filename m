From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: net/smc and the RDMA core
Date: Thu, 4 May 2017 09:31:55 -0600
Message-ID: <20170504153155.GB854@obsidianresearch.com>
References: <20170501163311.GA22209@lst.de>
 <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
 <1493750358.2552.13.camel@sandisk.com>
 <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
 <20170504084825.GA5399@lst.de>
 <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "hch@lst.de" <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:44592 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751248AbdEDPcI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 11:32:08 -0400
Content-Disposition: inline
In-Reply-To: <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 03:08:39PM +0200, Ursula Braun wrote:
> 
> 
> On 05/04/2017 10:48 AM, hch@lst.de wrote:
> > On Thu, May 04, 2017 at 11:43:50AM +0300, Sagi Grimberg wrote:
> >> I would also suggest that you stop exposing the DMA MR for remote
> >> access (at least by default) and use a proper reg_mr operations with a
> >> limited lifetime on a properly sized buffer.
> > 
> > Yes, exposing the default DMA MR is a _major_ security risk.  As soon
> > as SMC is enabled this will mean a remote system has full read/write
> > access to the local systems memory.
> > 
> > There ??s a reason why I removed the ib_get_dma_mr function and replaced
> > it with the IB_PD_UNSAFE_GLOBAL_RKEY key that has _UNSAFE_ in the name
> > and a very long comment explaining why, and I'm really disappointed that
> > we got a driver merged that instead of asking on the relevant list on
> > why a change unexpertong a function it needed happened and instead
> > tried the hard way to keep a security vulnerarbility alive.
> > 
> Thanks for pointing out these problems. We will address them.

So, you've created a huge security hole in the kernel, anyone who
loads your smc module is vunerable.

What are you going to do *RIGHT NOW* to mitigate this?

Jason
