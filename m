From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 30/30] nfs: fix various memory recursions possible with swap over NFS.
Date: Fri, 25 Jul 2008 19:46:59 +0900
Message-ID: <20080725194517.86BB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080724140042.408642539@chello.nl> <20080724141531.486682621@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:48042 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbYGYKsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:48:01 -0400
In-Reply-To: <20080724141531.486682621@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> GFP_NOFS is not enough, since swap traffic is IO, hence fall back to GFP_NOIO.

this comment imply turn on GFP_NOIO, but the code is s/NOFS/NOIO/. why?



>  struct nfs_write_data *nfs_commitdata_alloc(void)
>  {
> -	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
> +	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);




