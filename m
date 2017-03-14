From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v1 for accelerated IPoIB 25/25] mlx5_ib: skeleton for
 mlx5_ib to support ipoib_ops
Date: Tue, 14 Mar 2017 10:10:13 -0600
Message-ID: <20170314161013.GF3244@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-26-git-send-email-erezsh@mellanox.com>
 <20170313202720.GC2738@obsidianresearch.com>
 <CAAk-MO9ekfWZT-C2SKTw129t=UQty9w2+wzQsvY1Od0k1zSrpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Shitrit <erezsh@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev@vger.kernel.org, valex@mellanox.com,
        Leon Romanovsky <leonro@mellanox.com>, saedm@mellanox.com
To: Erez Shitrit <erezsh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:37021 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751635AbdCNQKP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 12:10:15 -0400
Content-Disposition: inline
In-Reply-To: <CAAk-MO9ekfWZT-C2SKTw129t=UQty9w2+wzQsvY1Od0k1zSrpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 04:53:24PM +0200, Erez Shitrit wrote:

> > Why isn't this stuff in open/close?
> 
> According to ipoib control flows, there is a different between
> open/close to init/cleanup for example, in open/close the driver
> doesn't destroy hw resources, just change the state, it destroys
> them in cleanup.

So put it in mlx5_alloc_rdma_netdev then?

Or ndo.init as was suggested?

Or in the void (*setup)(struct net_device *)

> >> +     param.size_base_priv = sizeof(struct ipoib_rdma_netdev);
> >
> > This is really weird, the code in mlx5i_create_netdev calls
> > ipoib_dev_priv so it must assume the struct is a ipoib_rdma_netdev.
> 
> It is the same attitude as in the vnic/hfi
> (https://patchwork.kernel.org/patch/9587815/)

Not quite, they call alloc_netdev_mqs directly, here indirects through
mlx5i_create_netdev which assumes a priv layout, Just drop
param.size_base_priv and put that same calculation in
mlx5i_create_netdev..

Jason
