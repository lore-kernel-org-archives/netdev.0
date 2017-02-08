From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Wed, 8 Feb 2017 10:29:12 -0700
Message-ID: <20170208172912.GA30720@obsidianresearch.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207211901.GB28922@obsidianresearch.com>
 <20170208065437.GA6005@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com, Liran Liss <liranl@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:39584 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753186AbdBHRxs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 12:53:48 -0500
Content-Disposition: inline
In-Reply-To: <20170208065437.GA6005@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 08:54:37AM +0200, Leon Romanovsky wrote:
> On Tue, Feb 07, 2017 at 02:19:01PM -0700, Jason Gunthorpe wrote:
> > On Tue, Feb 07, 2017 at 12:23:01PM -0800, Vishwanathapura, Niranjana wrote:
> > > Add rdma netdev interface to ib device structure allowing rdma netdev
> > > devices to be allocated by ib clients.
> > > Define HFI VNIC interface between hardware independent VNIC
> > > functionality and the hardware dependent VNIC functionality.
> >
> > This commit message could be a bit clearer.
> >
> > The alloc_rdma_netdev multiplexer is inteded as a new general
> > interface and this adds a protocol definition for ethernet VNIC on
> > OPA.
> >
> > The hope is that ipoib can follow the same example and use the same
> > alloc_rdma_netdev entry point. Hopefully Mellanox will look at this
> > patch as I have talked to them in the past about doing this...
> 
> We looked on it and it is useless for us, mainly because of the fact
> that most  of the work is done in our net part of the driver.

I don't understand this comment.

At the last OFA conference the discussion with Mellanox was to provide
a way to implement ipoib ndo_start_xmit (and others) inside the lowest
level driver so the driver could do all offloads and optimizations
when pushing the ipoib SKB on the wire (and similar for rx). The ipoib
control plane would remain in the ipoib driver.

This is exactly the split that Vishwanathapura has created for
vnic. It has greatly simplified their code design from the earlier
patch series, so it seems like the right approach so far.

ipoib is not really any different from this vnic stuff. Both have
complex control planes that must be shared and need highly device
specific tx/rx flows.

I certainly don't want to see some other proposal to optimize ipoib ..

Jason
