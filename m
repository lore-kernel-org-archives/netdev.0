From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Crash in tun
Date: Fri, 20 Jul 2012 11:23:37 -0700 (PDT)
Message-ID: <20120720.112337.474955511809249636.davem@davemloft.net>
References: <alpine.DEB.2.00.1207190213001.16299@artax.karlin.mff.cuni.cz>
	<1342678175.2626.3849.camel@edumazet-glaptop>
	<alpine.DEB.2.00.1207191746170.7550@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, maxk@qualcomm.com, vtun@office.satix.net,
	netdev@vger.kernel.org
To: mikulas@artax.karlin.mff.cuni.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751Ab2GTSXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:23:38 -0400
In-Reply-To: <alpine.DEB.2.00.1207191746170.7550@artax.karlin.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Date: Thu, 19 Jul 2012 18:13:36 +0200 (CEST)

> tun: fix a crash bug and a memory leak
> 
> This patch fixes a crash
> tun_chr_close -> netdev_run_todo -> tun_free_netdev -> sk_release_kernel ->
> sock_release -> iput(SOCK_INODE(sock))
> introduced by commit 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d
> 
> The problem is that this socket is embedded in struct tun_struct, it has
> no inode, iput is called on invalid inode, which modifies invalid memory
> and optionally causes a crash.
> 
> sock_release also decrements sockets_in_use, this causes a bug that
> "sockets: used" field in /proc/*/net/sockstat keeps on decreasing when
> creating and closing tun devices.
> 
> This patch introduces a flag SOCK_EXTERNALLY_ALLOCATED that instructs
> sock_release to not free the inode and not decrement sockets_in_use,
> fixing both memory corruption and sockets_in_use underflow.
> 
> It should be backported to 3.3 an 3.4 stabke.
> 
> Signed-off-by: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
> Cc: stable@kernel.org

Applied.
