From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: kill ht->shift atomic operations
Date: Thu, 12 Mar 2015 23:01:50 -0400 (EDT)
Message-ID: <20150312.230150.2105637144692337929.davem@davemloft.net>
References: <04e26545f9d1b1fbd1297e5701ae72e12539091e.1426156183.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, ying.xue@windriver.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbCMDBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:01:51 -0400
In-Reply-To: <04e26545f9d1b1fbd1297e5701ae72e12539091e.1426156183.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 12 Mar 2015 15:28:40 +0100

> Commit c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for worker
> queue") changed ht->shift to be atomic, which is actually unnecessary.
> 
> Instead of leaving the current shift in the core rhashtable structure,
> it can be cached inside the individual bucket tables.
> 
> There, it will only be initialized once during a new table allocation
> in the shrink/expansion slow path, and from then onward it stays immutable
> for the rest of the bucket table liftime.
> 
> That allows shift to be non-atomic. The patch also moves hash_rnd
> management into the table setup. The rhashtable structure now consumes
> 3 instead of 4 cachelines.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
