From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/5] SUNRPC: create unix gid cache per network namespace
Date: Thu, 19 Jan 2012 11:24:31 -0500
Message-ID: <20120119162431.GC527@fieldses.org>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
 <20120119144914.9957.73951.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	xemul@parallels.com, neilb@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jbottomley@parallels.com,
	davem@davemloft.net, devel@openvz.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120119144914.9957.73951.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2012 at 06:49:14PM +0400, Stanislav Kinsbursky wrote:
> This patch makes unix_gid_cache cache detail allocated and registered per
> network namespace context.
> Thus with this patch unix_gid_cache contents for network namespace "X" are
> controlled from proc file system mount for the same network namespace "X".

I'm confused--this seems half-done.  I see that you're creating the gid
caches dynamically, but there's still this static definition:

>  struct cache_detail unix_gid_cache = {
>  	.owner		= THIS_MODULE,
>  	.hash_size	= GID_HASHMAX,
> -	.hash_table	= gid_table,
>  	.name		= "auth.unix.gid",
>  	.cache_put	= unix_gid_put,
>  	.cache_upcall	= unix_gid_upcall,

And it looks like unix_gid_lookup is still using this static
unix_gid_cache.  Maybe I'm missing something....

--b.
