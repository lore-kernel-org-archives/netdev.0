From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] fib_trie: Cleanup ip_fib_net_exit code
 path
Date: Tue, 31 Mar 2015 13:19:39 -0400 (EDT)
Message-ID: <20150331.131939.381866350778083657.davem@davemloft.net>
References: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
	<20150327211422.2465.50276.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbbCaRTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:19:40 -0400
In-Reply-To: <20150327211422.2465.50276.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 27 Mar 2015 14:14:22 -0700

> While fixing a recent issue I noticed that we are doing some unnecessary
> work inside the loop for ip_fib_net_exit.  As such I am pulling out the
> initialization to NULL for the locally stored fib_local, fib_main, and
> fib_default.
> 
> In addition I am restoring the original code for flushing the table as
> there is no need to split up the fib_table_flush and hlist_del work since
> the code for packing the tnodes with multiple key vectors was dropped.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied.

I also agree with you that we shouldn't try to get too fancy
here as Cong is suggesting, lest ->delete() have other side
effects in the future.

Thanks.
