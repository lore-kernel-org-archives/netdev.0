From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/4] rtnetlink: Add get_link_af_size_filtered
 to rtnl_af_ops
Date: Wed, 14 Oct 2015 11:55:18 +0200
Message-ID: <20151014115518.071a3996@griffin>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
	<1444802314-28830-2-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ronen Arad <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbbJNJzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 05:55:21 -0400
In-Reply-To: <1444802314-28830-2-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Oct 2015 22:58:31 -0700, Ronen Arad wrote:
> --- a/include/net/rtnetlink.h
> +++ b/include/net/rtnetlink.h
> @@ -130,6 +130,8 @@ struct rtnl_af_ops {
>  						    const struct nlattr *attr);
>  	int			(*set_link_af)(struct net_device *dev,
>  					       const struct nlattr *attr);
> +	size_t			(*get_link_af_size_filtered)(const struct net_device *dev,
> +							     u32 ext_filter_mask);
>  };

There's not much point in having two callbacks doing essentially the
same. Why you just don't add the new parameter to the existing
get_link_af_size? Looking at what the patch 3 does, the current
implementations of the callback can just ignore the new parameter and
bridge can remove the current br_get_link_af and rename
br_get_link_af_size_filtered to br_get_link_af.

 Jiri

-- 
Jiri Benc
