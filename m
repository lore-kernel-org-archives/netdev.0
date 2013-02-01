From: Matt Helsley <matthltc@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 3/4] netns: bridge: allow unprivileged users
 add/delete mdb entry
Date: Thu, 31 Jan 2013 19:46:29 -0800
Message-ID: <20130201034629.GE8400@us.ibm.com>
References: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1359685860-29636-3-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, ebiederm@xmission.com,
	pablo@netfilter.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:60230 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab3BADqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 22:46:37 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <matthltc@linux.vnet.ibm.com>;
	Thu, 31 Jan 2013 20:46:37 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 028881FF0038
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 20:46:34 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r113kYCH086014
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 20:46:34 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r113kWHP021473
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 20:46:34 -0700
Content-Disposition: inline
In-Reply-To: <1359685860-29636-3-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 10:30:59AM +0800, Gao feng wrote:
> since the mdb table is belong to bridge device,and the
> bridge device can only be seen in one netns.
> So it's safe to allow unprivileged user which is the
> creator of userns and netns to modify the mdb table.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/bridge/br_mdb.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
> index acc9f4c..38991e0 100644
> --- a/net/bridge/br_mdb.c
> +++ b/net/bridge/br_mdb.c
> @@ -272,9 +272,6 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
>  	struct net_device *dev;
>  	int err;
> 
> -	if (!capable(CAP_NET_ADMIN))
> -		return -EPERM;
> -

I'm wondering why this doesn't follow the:

...
- if (!capable(CAP_NET_ADMIN))
+ if (!ns_capable(net->user_ns, CAP_NET_ADMIN))

pattern like the rest of the changes you provided. Perhaps I'm
neglecting something but it looks wrong to remove the CAP_NET_ADMIN
check entirely.

Cheers,
	-Matt Helsley
