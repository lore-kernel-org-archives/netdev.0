From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: fix address check in rtnl_fdb_del
Date: Tue, 23 Apr 2013 21:47:55 +0100
Message-ID: <1366750075.4016.34.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366749559-9868-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dlstevens@us.ibm.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7707 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216Ab3DWUr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 16:47:59 -0400
In-Reply-To: <1366749559-9868-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 16:39 -0400, Vlad Yasevich wrote:
> Commit 6681712d67eef14c4ce793561c3231659153a320
> 	vxlan: generalize forwarding tables
> 
> relaxed the address checks in rtnl_fdb_del() to use is_zero_ether_addr().
> This allows users to add multicast addresses using the fdb API.  However,
> the check in rtnl_fdb_del() still uses a more strict
> is_valid_ether_addr() which rejects multicast addresses.  Thus it
> is possible to add an fdb that can not be later removed.
> Relax the check in rtnl_fdb_del() as well.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 18af08a..2c54cc1 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2192,7 +2192,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	}
>  
>  	addr = nla_data(tb[NDA_LLADDR]);
> -	if (!is_valid_ether_addr(addr)) {
> +	if (!is_zero_ether_addr(addr)) {

This is the opposite of what you want.

Ben.

>  		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ether address\n");
>  		return -EINVAL;
>  	}

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
