From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 23 Nov 2011 07:09:37 -0500
Message-ID: <20111123120937.GB27968@hmsreliant.think-freely.org>
References: <20111123150004.59be04eb36c480ec44edc9d5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34923 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab1KWMJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 07:09:46 -0500
Content-Disposition: inline
In-Reply-To: <20111123150004.59be04eb36c480ec44edc9d5@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 03:00:04PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the final tree, today's linux-next build (powerpc allnoconfig)
> failed like this:
> 
> In file included from include/linux/netdevice.h:53:0,
>                  from include/linux/icmpv6.h:173,
>                  from include/linux/ipv6.h:220,
>                  from include/net/ipv6.h:16,
>                  from include/linux/sunrpc/clnt.h:26,
>                  from include/linux/nfs_fs.h:50,
>                  from init/do_mounts.c:20:
> include/net/netprio_cgroup.h:23:29: error: field 'css' has incomplete type
> 
> And several more similar.
> 
> Caused by commit 5bc1421e34ec ("net: add network priority cgroup
> infrastructure (v4)").
> 
> I have added the following (minimal, but probably not optimal) patch for
> today:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 23 Nov 2011 14:49:49 +1100
> Subject: [PATCH] net: fix build error in network priority cgroup
>  infrastructure
> 
> Fixes this error:
> 
> In file included from include/linux/netdevice.h:53:0,
>                  from include/linux/icmpv6.h:173,
>                  from include/linux/ipv6.h:220,
>                  from include/net/ipv6.h:16,
>                  from include/linux/sunrpc/clnt.h:26,
>                  from include/linux/nfs_fs.h:50,
>                  from init/do_mounts.c:20:
> include/net/netprio_cgroup.h:23:29: error: field 'css' has incomplete type
> 
> When CONFIG_CGROUPS is not set.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  include/net/netprio_cgroup.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
> index c432e99..da71b91 100644
> --- a/include/net/netprio_cgroup.h
> +++ b/include/net/netprio_cgroup.h
> @@ -20,7 +20,9 @@
>  
>  struct cgroup_netprio_state
>  {
> +#ifdef CONFIG_CGROUPS
>  	struct cgroup_subsys_state css;
> +#endif
>  	u32 prioidx;
>  };
>  
> -- 
> 1.7.7.3
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
FYI, I've got a more appropriate fix building right now getting posted for the
net-next tree.  I'll cc you on it.

Neil
