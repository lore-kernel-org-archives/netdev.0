From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Fri, 21 Jul 2017 09:53:36 -0600
Message-ID: <2b230990-eeb5-9ea4-7dbc-212bf7ff61a5@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        WANG Cong <xiyou.wangcong@gmail.com>
To: Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34743 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753527AbdGUPxo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 11:53:44 -0400
Received: by mail-pf0-f174.google.com with SMTP id q85so25588853pfq.1
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 08:53:44 -0700 (PDT)
In-Reply-To: <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/20/17 9:23 AM, Hangbin Liu wrote:
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96..c290aa4 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -3637,13 +3637,8 @@ static int inet6_rtm_getroute(struct sk_buff
> *in_skb, struct nlmsghdr *nlh,
>                 dst = ip6_route_lookup(net, &fl6, 0);
> 
>         rt = container_of(dst, struct rt6_info, dst);
> -       if (rt->dst.error) {
> -               err = rt->dst.error;
> -               ip6_rt_put(rt);
> -               goto errout;
> -       }

The above 5 lines introduced the change in behavior, so removing them
should be sufficient.
