From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] marvell: mark mvneta and mvpp2 32-bit only
Date: Tue, 22 Nov 2016 10:09:15 -0500 (EST)
Message-ID: <20161122.100915.1530014321160359051.davem@davemloft.net>
References: <20161122142136.1690096-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com, f.fainelli@gmail.com,
        mw@semihalf.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932592AbcKVPQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 10:16:59 -0500
In-Reply-To: <20161122142136.1690096-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 22 Nov 2016 15:21:22 +0100

> Both of these drivers won't work on 64-bit architectures unless they
> are redesigned, since they store a virtual address pointer in a 32-bit
> field of the descriptors:
> 
> drivers/net/ethernet/marvell/mvneta_bm.c: In function 'mvneta_bm_construct':
> drivers/net/ethernet/marvell/mvneta_bm.c:103:16: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
> drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_vlan_init':
> drivers/net/ethernet/marvell/mvpp2.c:2563:32: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
> 
> This limits the COMPILE_TEST option for the two drivers again to
> only build them on 32-bit. This seems nicer than shutting up the
> warnings, in case we ever actually want to use them on 64-bit,
> as the warnings indicate which parts of the driver are currently
> broken there.
> 
> Fixes: a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Ok, this is a reasonable thing to do for now until the 64-bit patches
are sorted out.

Applied, thanks Arnd.
