From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [1/2] POHMELFS - network filesystem with local coherent cache.
Date: Fri, 1 Feb 2008 02:04:39 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802010159460.4864@fbirervta.pbzchgretzou.qr>
References: <11972872493911@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:48142 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbYBABEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:04:40 -0500
In-Reply-To: <11972872493911@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 31 2008 22:17, Evgeniy Polyakov wrote:
>
>POHMELFS stands for Parallel Optimized Host Message Exchange
>Layered File System. It allows to mount remote servers to local
>directory via network. This filesystem supports local caching
>and writeback flushing.
>POHMELFS is a brick in a future distributed filesystem.

A brick is usually something that is in the way -
Or you also say "the user has bricked his machine"
when it's quite unusable :)
Hope you did not mean /that/.

>This set includes two patches:
> * network filesystem with write-through cache (slow, but works with
> 	remote userspace server)
> * hack to show how local cache works and how faster it is compared
> 	to async NFS (see below). hack disables writeback flush and
>	performs local allocation of the objects only.
>
>Now, some vaporware aka food for thoughts and your brains.
>
>A small benchmark of the local cached mode (above hack):
>
>$ time tar -xf /home/zbr/threading.tar
>
>	POHMELFS	NFS v3 (async)
>real    0m0.043s	0m1.679s
>
>Which is damn 40 times!

Needs a bigger data set to compare. But what is much more
important: does it use a single port for networing, or some
firewall-unfriendly-by-default multiple dynamic-port-allocation
like NFS?

>Next task is to think about how to generically solve the problem with
>syncing local changes with remote server, when remote server maintains inodes with
>completely different numbers.
>This, among others, will allow offline work with automatic syncing after reconnect.

What will happen when both nodes change an inode in disconnected state?
Which inode wins out?

>This is not intended for inclusion, CRFS by Zach Brown is a bit ahead of POHMELFS,
>but it is not generic enough (because of above problem), works only with BTRFS,
>and was closed by Oracle so far :)

btrfs is all we need :p


Where's the parallelism that is advertised by the "POH" in pohmelfs?
