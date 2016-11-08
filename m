From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: Correct /proc/net/route off by one error
Date: Mon, 07 Nov 2016 20:41:01 -0500 (EST)
Message-ID: <20161107.204101.435373917046293969.davem@davemloft.net>
References: <20161104191157.13974.70665.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
        apw@canonical.com, jbaron@akamai.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbcKHBmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:42:00 -0500
In-Reply-To: <20161104191157.13974.70665.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 04 Nov 2016 15:11:57 -0400

> The display of /proc/net/route has had a couple issues due to the fact that
> when I originally rewrote most of fib_trie I made it so that the iterator
> was tracking the next value to use instead of the current.
> 
> In addition it had an off by 1 error where I was tracking the first piece
> of data as position 0, even though in reality that belonged to the
> SEQ_START_TOKEN.
> 
> This patch updates the code so the iterator tracks the last reported
> position and key instead of the next expected position and key.  In
> addition it shifts things so that all of the leaves start at 1 instead of
> trying to report leaves starting with offset 0 as being valid.  With these
> two issues addressed this should resolve any off by one errors that were
> present in the display of /proc/net/route.
> 
> Fixes: 25b97c016b26 ("ipv4: off-by-one in continuation handling in /proc/net/route")
> Cc: Andy Whitcroft <apw@canonical.com>
> Reported-by: Jason Baron <jbaron@akamai.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied and queued up for -stable.
