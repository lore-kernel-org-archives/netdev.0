From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Fri, 31 Jul 2015 12:40:14 +0300
Message-ID: <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Somnath Kotur <Somnath.Kotur@avagotech.com>,
	Moni Shoua <monis@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33037 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbbGaJkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 05:40:15 -0400
In-Reply-To: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2015 at 6:33 PM, Matan Barak <matanb@mellanox.com> wrote:

[...]

> Changes from V6:
> (1) Addressed Jason's comments:
>         (a) Cache is no longer a client but part of IB infrastructure
>         (b) No need for READ_ONCE and flush_workqueue when tearing down
>             the cache

Doug

So... are we ready to go with V7 upstream?

Or.


> Changes from V5:
> (1) Incoporate the changes to cache.c so we use the same infrastructure
>     to manage both IB and RoCE (per Doug's request)
> (2) Replace the locking mechanism in the IB core GID cache from seqcount +
>     rcu to rwlock (addressing comments from Jason)
> (3) get_netdev returns a helded (dev_hold) device
> (4) Squashed the RocE GID table, RoCE GID management and default GID handling
>     code into one patch (per Doug's request).
> (5) Change modify_gid to add_gid and del_gid.
> (6) set the netdev related changes into three dedicated patches and make
>     them be 1st in the series.
>
> Changes from V4:
> (1) Remove any API changes.
> (2) Fixed a bug regarding bonding upper devices.
> (3) Rebased ontop of Doug's k.o/for-4.2.
>
> Changes from V3:
> (1) Remove RoCE V2 functionality (it will be sent at later patchset).
> (2) Instead of removing qp_attr_mask flags, reserve them.
> (3) Remove the kref from IB devices in favor of rwsem.
> (4) Change the name of roce_gid_cache to roce_gid_table.
> (5) Fix a race when roce_gid_table is free'd while getting events.
> (6) Remove the roce_gid_cache active/inactive flag/API.
