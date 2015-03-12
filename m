From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: kill ht->shift atomic operations
Date: Thu, 12 Mar 2015 14:43:08 +0000
Message-ID: <20150312144308.GB5378@casper.infradead.org>
References: <04e26545f9d1b1fbd1297e5701ae72e12539091e.1426156183.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50454 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbbCLOnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:43:11 -0400
Content-Disposition: inline
In-Reply-To: <04e26545f9d1b1fbd1297e5701ae72e12539091e.1426156183.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/15 at 03:28pm, Daniel Borkmann wrote:
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
> Cc: Ying Xue <ying.xue@windriver.com>

Very nice

Acked-by: Thomas Graf <tgraf@suug.ch>
