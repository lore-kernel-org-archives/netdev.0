From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC 2/3] genetlink: pass extended error report down
Date: Fri, 7 Apr 2017 11:37:07 -0700
Message-ID: <25e1fb8c-22e0-d7a2-13a7-d0def5432c9e@candelatech.com>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407182620.6438-3-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:43154 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934301AbdDGShK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:37:10 -0400
In-Reply-To: <20170407182620.6438-3-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2017 11:26 AM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  include/net/genetlink.h | 27 +++++++++++++++++++++++++++
>  net/netlink/genetlink.c |  6 ++++--
>  2 files changed, 31 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/genetlink.h b/include/net/genetlink.h
> index a34275be3600..67ad2326cfa6 100644
> --- a/include/net/genetlink.h
> +++ b/include/net/genetlink.h
> @@ -84,6 +84,7 @@ struct nlattr **genl_family_attrbuf(const struct genl_family *family);
>   * @attrs: netlink attributes
>   * @_net: network namespace
>   * @user_ptr: user pointers
> + * @exterr: extended error report struct
>   */
>  struct genl_info {
>  	u32			snd_seq;
> @@ -94,6 +95,7 @@ struct genl_info {
>  	struct nlattr **	attrs;
>  	possible_net_t		_net;
>  	void *			user_ptr[2];
> +	struct netlink_ext_err *exterr;
>  };
>
>  static inline struct net *genl_info_net(struct genl_info *info)
> @@ -106,6 +108,31 @@ static inline void genl_info_net_set(struct genl_info *info, struct net *net)
>  	write_pnet(&info->_net, net);
>  }
>
> +static inline int genl_err_str(struct genl_info *info, int err,
> +			       const char *msg)
> +{
> +	info->exterr->msg = msg;
> +
> +	return err;
> +}

I guess the error string must be constant and always available in memory
in this implementation?

I think it would be nice to dynamically create strings (malloc, snprintf, etc)
and have the err_str logic free it when done?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
