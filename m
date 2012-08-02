From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 06/12] net/core: Add rtnetlink support to vif
 parameters
Date: Thu, 2 Aug 2012 01:20:37 +0100
Message-ID: <1343866837.2602.64.camel@bwh-desktop.uk.solarflarecom.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	 <1343840975-3252-7-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21277 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750776Ab2HBAUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 20:20:41 -0400
In-Reply-To: <1343840975-3252-7-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-01 at 20:09 +0300, Or Gerlitz wrote:
> From: Erez Shitrit <erezsh@mellanox.co.il>
> 
> Add IFLA_VIF_INFO which allows user space to configure mac/vlan for a VIF
[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -780,7 +780,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>  	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
>  	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
> -	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
> +	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> +	       + nla_total_size(sizeof(struct ifla_vif_param)); /* IFLA_VIF_INFO */
>  }
[...]

if_nlmsg_size() returns the size of a message describing the interface.
But IFLA_VIF_INFO is write-only (why?) and therefore shouldn't be
included.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
