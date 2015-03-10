From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] fib_trie: Address possible NULL pointer
 dereference in resize
Date: Tue, 10 Mar 2015 18:37:09 -0400 (EDT)
Message-ID: <20150310.183709.1610621985670217289.davem@davemloft.net>
References: <20150310213929.2235.18452.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbbCJWhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:37:11 -0400
In-Reply-To: <20150310213929.2235.18452.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 10 Mar 2015 14:39:34 -0700

> If the inflate call failed it would return NULL.  As a result tp would be
> set to NULL and cause use to trigger a NULL pointer dereference in
> should_halve if the inflate failed on the first attempt.
> 
> In order to prevent this we should decrement max_work before we actually
> attempt to inflate as this will force us to exit before attempting to halve
> a node we should have inflated.  In order to keep things symmetric between
> inflate and halve I went ahead and also moved the decrement of max_work for
> the halve case as well so we take care of that before we actually attempt
> to halve the tnode.
> 
> Fixes: 88bae714 ("fib_trie: Add key vector to root, return parent key_vector in resize")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks Alex.
