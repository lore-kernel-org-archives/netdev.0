From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: Bug fix for incorrect interpretation of MLDv2
 maximum response code
Date: Thu, 13 Dec 2012 16:12:01 -0800
Message-ID: <20121213161201.6d2da433@nehalam.linuxnetplumber.net>
References: <50CA6DA5.1020101@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58997 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab2LNANV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 19:13:21 -0500
In-Reply-To: <50CA6DA5.1020101@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2012 08:07:01 +0800
Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:

> This patch fixes the incorrect interpretation of endianness of MLDv2 maximum response
> code within bridge's multicast snooping code.
> 
> Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
> ---
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 977c3ee..29c6283 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1172,7 +1172,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
>  		mld2q = (struct mld2_query *)icmp6_hdr(skb);
>  		if (!mld2q->mld2q_nsrcs)
>  			group = &mld2q->mld2q_mca;
> -		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
> +		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : 1;
>  	}
>  
>  	if (!group)

Already fixed as part of my patch to fix sparse warnings.
