From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: disable fragment reassembly if
 high_thresh is zero
Date: Sun, 05 Jun 2016 22:57:40 -0400 (EDT)
Message-ID: <20160605.225740.668676557934559956.davem@davemloft.net>
References: <20160602203318.1CF6FA0E60@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbcFFC5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 22:57:44 -0400
In-Reply-To: <20160602203318.1CF6FA0E60@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 27 May 2016 17:53:52 +0200

> Before commit 6d7b857d541e ("net: use lib/percpu_counter API for
> fragmentation mem accounting"), setting the reassembly high threshold
> to 0 prevented fragment reassembly as first fragment would be always
> evicted before second could be added to the queue. While inefficient,
> some users apparently relied on this method.
> 
> Since the commit mentioned above, a percpu counter is used for
> reassembly memory accounting and high batch size avoids taking slow path
> in most common scenarios. As a result, a whole full sized packet can be
> reassembled without the percpu counter's main counter changing its value
> so that even with high_thresh set to 0, fragmented packets can be still
> reassembled and processed.
> 
> Add explicit check preventing reassembly if high threshold is zero.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, thanks.
