From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 7/8] net: ipv4: RTM_GETROUTE: return matched fib
 result when requested
Date: Wed, 24 May 2017 20:16:33 -0600
Message-ID: <a37fba63-c015-2773-0632-5a1f7f0d82e2@gmail.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
 <1495649951-30417-8-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33393 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755139AbdEYCQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 22:16:35 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so35887133pfe.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 19:16:35 -0700 (PDT)
In-Reply-To: <1495649951-30417-8-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/24/17 12:19 PM, Roopa Prabhu wrote:

> @@ -2746,8 +2748,15 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>  	if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)
>  		table_id = rt->rt_table_id;
>  
> -	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
> -			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq, rt);
> +	if (rtm->rtm_flags & RTM_F_FIB_MATCH)
> +		err = fib_dump_info(skb, NETLINK_CB(in_skb).portid,
> +				    nlh->nlmsg_seq, RTM_NEWROUTE, table_id,
> +				    rt->rt_type, res.prefix, res.prefixlen,
> +				    fl4.flowi4_tos, res.fi, 0);

I like this part -- much simpler than duplicating the attributes which
is where I was headed.
