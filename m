From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to
 neighbouring system
Date: Fri, 20 Jul 2012 18:49:16 +0300
Message-ID: <CAJZOPZ+kRcBjJgB_HaMqeuB5E-SLSqskgoaLZ_hvVx4KffHgpA@mail.gmail.com>
References: <1342703938-29904-1-git-send-email-ogerlitz@mellanox.com>
	<1342703938-29904-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma@vger.kernel.org, erezsh@mellanox.com,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:34522 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab2GTPtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:49:18 -0400
In-Reply-To: <1342703938-29904-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 19, 2012 at 4:18 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> From: Shlomo Pongratz <shlomop@mellanox.com>
>
> Dave Miller <davem@davemloft.net> provided a detailed description of why the
> way IPoIB is using neighbours for its own ipoib_neigh struct is buggy:
[...]

> This patch aims to solve the race conditions found in the IPoIB driver.
>
> The patch breaks the connection between the core networking neighbour structure
> and the ipoib_neigh structure. Except for avoiding the race, it allows to in
> under a setup where SKBs carrying IP packets that don't have any associated
> neighbour are transmitted through IPoIB.
>
> We add an ipoib_neigh hash table with 1024 buckets. The hash table key is the destin
> hardware address. Thus the ipoib_neigh is fetched from the hash table and not
> dereferenced from the stashed location at the neighbour structure. The hash table uses
> both RCU and reference count mechanisms to guarantee that no ipoib_neigh instance is
> ever deleted while in use.
>
> Fetching the ipoib_neigh structure instance from the hash also makes the special
> code in ipoib_start_xmit that handles remote and local bonding failover redundant.
>
> Aged ipoib_neigh instances are deleted by a garbage collection task that runs every
> 30 seconds and deletes every ipoib_neigh instance that was idle for at least 60
> seconds. The deletion is safe since the ipoib_neigh instances are protected
> using RCU and reference count mechanisms.

Hi Dave, Roland, Eric

So how does this look? in the right direction? anything that need to be fixed?

Or.
