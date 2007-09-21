From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3 Rev4] Initialize and fill IPv6 route age
Date: Fri, 21 Sep 2007 10:00:35 +0530
Message-ID: <46F348EB.1080402@linux.vnet.ibm.com>
References: <OF5159F66B.5A5F01B8-ON6525735D.000FD530-6525735D.0010F45F@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, socketcan@hartkopp.net,
	tgraf@suug.ch, Varun Chandramohan <varuncha@in.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:46007 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbXIUE3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 00:29:25 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8L4TOLD005575
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:29:24 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8L4TOgt695586
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:29:24 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8L4TN8a005688
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:29:24 -0400
In-Reply-To: <OF5159F66B.5A5F01B8-ON6525735D.000FD530-6525735D.0010F45F@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
> Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote on 09/20/2007 08:59:03
> PM:
>
>   
>> @@ -2123,6 +2131,7 @@ static int rt6_fill_node(struct sk_buff
>>  {
>>     struct rtmsg *rtm;
>>     struct nlmsghdr *nlh;
>> +   struct timeval tv;
>>     long expires;
>>     u32 table;
>>
>> @@ -2186,6 +2195,11 @@ static int rt6_fill_node(struct sk_buff
>>        if (ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf) == 0)
>>           NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
>>     }
>> +
>> +   do_gettimeofday(&tv);
>> +   if (rt->rt6i_age) {
>> +      NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - rt->rt6i_age));
>> +   }
>>     
>
> Will rt6i_age ever be zero with this new patch? If it can be zero,
> the code should really be keeping the "tv" declaration and
> do_gettimeofday() inside the "if (rt->rt6i_age)" check.
>
>   
No, it will be zero only if some new code added doesnt initialize the
route age. I will update this change in my next patch release.
> And from your Patch2/3:
>
> int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
> -                          u32 tb_id, u8 type, u8 scope, __be32 dst, int
> dst_len, u8 tos,
> +                          u32 tb_id, u8 type, u8 scope, __be32 dst, int
> dst_len, u8 tos, time_t age,
>                            struct fib_info *fi, unsigned int flags)
>  {
>              struct nlmsghdr *nlh;
>              struct rtmsg *rtm;
> +            struct timeval tv;
>
>              nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
>              if (nlh == NULL)
> @@ -985,6 +987,11 @@ int fib_dump_info(struct sk_buff *skb, u
>                                      NLA_PUT_U32(skb, RTA_FLOW,
> fi->fib_nh[0].nh_tclassid);
>  #endif
>              }
> +
> +            do_gettimeofday(&tv);
> +            if (age) {
> +                        NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - age));
> +            }
>
> Don't you want to return time the first time (and get zero)? Otherwise
> RTA_AGE is not returned to user. Something like:
>
>   
The first time it will be zero.
>             do_gettimeofday(&tv);
>             NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - age));
>
> Once again, can age ever be zero?
>
>   
same as above.
> - KK
>
>   

