From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Mon, 26 Jun 2017 14:36:10 -0600
Message-ID: <20170626203610.GB17892@obsidianresearch.com>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:51702 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751403AbdFZUgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 16:36:25 -0400
Content-Disposition: inline
In-Reply-To: <20170626192103.GH1248@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 26, 2017 at 10:21:03PM +0300, Leon Romanovsky wrote:
> On Mon, Jun 26, 2017 at 12:29:24PM -0600, Jason Gunthorpe wrote:
> > On Mon, Jun 26, 2017 at 09:21:26PM +0300, Leon Romanovsky wrote:
> > > From: Leon Romanovsky <leonro@mellanox.com>
> > >
> > > Add parsing interface for the device capability flags
> > >
> > > $ rdma dev show
> > > 1: mlx5_0: caps 0x1257e1c26
> >
> > This seems very un ip-like. I wouldn't show an undecoded hex value
> > like that, it isn't really useful.
> 
> It is first supported field, after new fields will be added, we will
> have very similar to ip interface.
> 
> 1: mlx5_0: caps 0x1257e1c2 key_1 val_1 key_2 val_2 ....
> 
> The value are presented as is can be usable as an input for different scripts.

I still wouldn't show an undecoded hex value.. It isn't useful.

> > > $ rdma dev show mlx5_4 caps
> > > 5: mlx5_4: caps 0x1257e1c26
> > > Bit	Description
> > >  01	DEVICE_BAD_PKEY_CNTR
> > >  02	DEVICE_BAD_QKEY_CNTR
> >
> > This table also seems un ip-like, the usual format is a list of words,
> > I think.
> 
> It is true for key<->value data, but it is less obvious for bit
> parsing.

Several of the word decodes are from bit fields..

> Internally, I tried to present them as list and it was ugly like hell
> without any chance (without extra parsing) to actual see if specific
> capability is present or no.

lspci seems to have no problem being readable while doing this..

Jason
