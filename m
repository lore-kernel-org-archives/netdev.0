From: David Miller <davem@davemloft.net>
Subject: Re: [Patch-next] Fix the size overflow of addrconf_sysctl array
Date: Thu, 08 Oct 2009 22:44:15 -0700 (PDT)
Message-ID: <20091008.224415.205034676.davem@davemloft.net>
References: <4ACEA207.7010208@np.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, cratiu@ixiacom.com,
	opurdila@ixiacom.com, kaneshige.kenji@jp.fujitsu.com,
	seto.hidetoshi@jp.fujitsu.com, netdev@vger.kernel.org
To: jin.dongming@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751607AbZJIFoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 01:44:19 -0400
In-Reply-To: <4ACEA207.7010208@np.css.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jin Dongming <jin.dongming@np.css.fujitsu.com>
Date: Fri, 09 Oct 2009 11:37:59 +0900

Please post networking patches always CC:'d to netdev@vger.kernel.org
so that it gets added to our networking patch tracking system at:

	http://patchwork.ozlabs.org/project/netdev/list/

Thank you.

I've applied your fix, thanks!

> (This patch fixes bug of commit f7734fdf61ec6bb848e0bafc1fb8bad2c124bb50
>  title "make TLLAO option for NA packets configurable")
> 
> When the IPV6 conf is used, the function sysctl_set_parent is called and the
> array addrconf_sysctl is used as a parameter of the function.
> 
> The above patch added new conf "force_tllao" into the array addrconf_sysctl,
> but the size of the array was not modified, the static allocated size is
> DEVCONF_MAX + 1 but the real size is DEVCONF_MAX + 2, so the problem is
> that the function sysctl_set_parent accessed wrong address.
> 
> I got the following information.
> Call Trace:
>     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
>     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
>     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
>     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
>     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
>     [<ffffffff810622d5>] __register_sysctl_paths+0xde/0x272
>     [<ffffffff8110892d>] ? __kmalloc_track_caller+0x16e/0x180
>     [<ffffffffa00cfac3>] ? __addrconf_sysctl_register+0xc5/0x144 [ipv6]
>     [<ffffffff8141f2c9>] register_net_sysctl_table+0x48/0x4b
>     [<ffffffffa00cfaf5>] __addrconf_sysctl_register+0xf7/0x144 [ipv6]
>     [<ffffffffa00cfc16>] addrconf_init_net+0xd4/0x104 [ipv6]
>     [<ffffffff8139195f>] setup_net+0x35/0x82
>     [<ffffffff81391f6c>] copy_net_ns+0x76/0xe0
>     [<ffffffff8107ad60>] create_new_namespaces+0xf0/0x16e
>     [<ffffffff8107afee>] copy_namespaces+0x65/0x9f
>     [<ffffffff81056dff>] copy_process+0xb2c/0x12c3
>     [<ffffffff810576e1>] do_fork+0x14b/0x2d2
>     [<ffffffff8107ac4e>] ? up_read+0xe/0x10
>     [<ffffffff81438e73>] ? do_page_fault+0x27a/0x2aa
>     [<ffffffff8101044b>] sys_clone+0x28/0x2a
>     [<ffffffff81011fb3>] stub_clone+0x13/0x20
>     [<ffffffff81011c72>] ? system_call_fastpath+0x16/0x1b
> 
> And the information of IPV6 in .config is as following.
> IPV6 in .config:
>     CONFIG_IPV6=m
>     CONFIG_IPV6_PRIVACY=y
>     CONFIG_IPV6_ROUTER_PREF=y
>     CONFIG_IPV6_ROUTE_INFO=y
>     CONFIG_IPV6_OPTIMISTIC_DAD=y
>     CONFIG_IPV6_MIP6=m
>     CONFIG_IPV6_SIT=m
>     # CONFIG_IPV6_SIT_6RD is not set
>     CONFIG_IPV6_NDISC_NODETYPE=y
>     CONFIG_IPV6_TUNNEL=m
>     CONFIG_IPV6_MULTIPLE_TABLES=y
>     CONFIG_IPV6_SUBTREES=y
>     CONFIG_IPV6_MROUTE=y
>     CONFIG_IPV6_PIMSM_V2=y
>     # CONFIG_IP_VS_IPV6 is not set
>     CONFIG_NF_CONNTRACK_IPV6=m
>     CONFIG_IP6_NF_MATCH_IPV6HEADER=m
> 
> I confirmed this patch fixes this problem.
> 
> Signed-off-by: Jin Dongming <jin.dongming@np.css.fujitsu.com>
> ---
>  include/linux/ipv6.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index ae74ede..5640425 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -208,6 +208,7 @@ enum {
>  	DEVCONF_MC_FORWARDING,
>  	DEVCONF_DISABLE_IPV6,
>  	DEVCONF_ACCEPT_DAD,
> +	DEVCONF_FORCE_TLLAO,
>  	DEVCONF_MAX
>  };
>  
> -- 
> 1.6.2.2
> 
> 
