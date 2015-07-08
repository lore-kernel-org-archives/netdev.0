From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v1 01/12] IB/core: pass client data to remove() callbacks
Date: Wed, 8 Jul 2015 14:29:10 -0600
Message-ID: <20150708202910.GA16812@obsidianresearch.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-2-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:58081 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758382AbbGHU3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 16:29:14 -0400
Content-Disposition: inline
In-Reply-To: <1434976961-27424-2-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2015 at 03:42:30PM +0300, Haggai Eran wrote:
> An ib_client callback that is called with the lists_rwsem locked only for
> read is protected from changes to the IB client lists, but not from
> ib_unregister_device() freeing its client data. This is because
> ib_unregister_device() will remove the device from the device list with
> lists_rwsem locked for write, but perform the rest of the cleanup,
> including the call to remove() without that lock.

I was going to look at this, but, uh.. it seems mangled, doesn't
apply, doesn't seem fixable from here.

It isn't on top of any of Doug's trees that I can find and it has
this:

> @@ -348,21 +348,22 @@ void ib_unregister_device(struct ib_device *device)
>  
>  	down_write(&lists_rwsem);
>  	list_del(&device->core_list);

..  lists_rwsem is what this patch is supposed to be adding, so I
don't know what went wrong here....

Jason
