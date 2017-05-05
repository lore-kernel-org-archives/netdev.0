From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: net/smc and the RDMA core
Date: Fri, 5 May 2017 11:10:17 -0600
Message-ID: <20170505171017.GA29554@obsidianresearch.com>
References: <20170501163311.GA22209@lst.de>
 <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
 <1493750358.2552.13.camel@sandisk.com>
 <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
 <20170504084825.GA5399@lst.de>
 <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5@linux.vnet.ibm.com>
 <20170504153155.GB854@obsidianresearch.com>
 <750b09b5-f898-fe7f-1e82-1f6c06cc0f58@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "hch@lst.de" <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:47888 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750734AbdEERKj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 13:10:39 -0400
Content-Disposition: inline
In-Reply-To: <750b09b5-f898-fe7f-1e82-1f6c06cc0f58@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 05, 2017 at 07:06:56PM +0200, Ursula Braun wrote:

> We do not see that just loading the smc module causes this issue.The security
> risk starts with the first connection, that actually uses smc. This is only
> possible if an AF_SMC socket connection is created while the so-called
> pnet-table is available and offers a mapping between the used Ethernet
> interface and RoCE device. Such a mapping has to be configured by a user
> (via a netlink interface) and, thus, is a conscious decision by that user.

At a mimimum this escaltes any local root exploit to a full kernel
exploit in the presense of RDMA hardware, so I do not think you should
be so dimissive of the impact.

I recommend immediately sending a kconfig patch cc'd to stable making
SMC require CONFIG_BROKEN so that nobody inadvertantly turns it on.

Jason
