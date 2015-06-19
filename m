From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Fri, 19 Jun 2015 08:14:11 -0700
Message-ID: <558431C3.5020703@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <55842A93.2040607@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34021 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754504AbbFSPOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:14:14 -0400
Received: by pdbki1 with SMTP id ki1so92769869pdb.1
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 08:14:14 -0700 (PDT)
In-Reply-To: <55842A93.2040607@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 7:43 AM, Robert Shearman wrote:
>> diff --git a/include/linux/lwtunnel.h b/include/linux/lwtunnel.h
>> new file mode 100644 
<snip>
>> +/* lw tunnel state flags */
>> +#define LWTUNNEL_STATE_OUTPUT_REDIRECT 0x1
>> +
>> +#define lwtunnel_output_redirect(lwtstate) (lwtstate && \
>> +            (lwtstate->flags & LWTUNNEL_STATE_OUTPUT_REDIRECT))
>
> This could be made an inline function for type-safety.
ack
>
>> +
>> +struct lwtunnel_state {
>> +    __u16        type;
>> +    __u16        flags;
>> +    atomic_t    refcnt;
>> +    struct lwtunnel_hdr tunnel;
>> +};
>> +
>> +struct lwtunnel_net {
>> +    struct hlist_head tunnels[LWTUNNEL_HASH_SIZE];
>> +};
>
> This type doesn't appear to be used in this patch series. Do you 
> intend to use it in a future version?
ack, will get rid of it
>
>>
>> +
>> +static inline struct lwtunnel_state *lwtunnel_skb_lwstate(struct 
>> sk_buff *skb)
>> +{
>> +    struct rtable *rt = (struct rtable *)skb_dst(skb);
>> +
>> +    return rt->rt_lwtstate;
>> +}
>
> It doesn't look like this patch will build on its own because 
> rt_lwtstate isn't added to struct rtable until patch 2.
looks like i messed up the patch creation. I will fix that with the next 
series.
>
> More importantly, is it safe to assume that skb_dst will always return 
> an IPv4 dst? How will this look when IPv6 support is added?

Today lwtunnel_skb_lwstate is called from lwtunnel_output which is only 
called from ipv4 code.
And my ipv6 variant code was supposed to have a 6 suffix. something like 
lwtunnel_output6.
Or to be more explicit i will probably have variants of the output and 
skb handling functions like,
lwtunnel_output_ipv4 and lwtunnel_output_ipv6.
>> +
>> +    ret = -EOPNOTSUPP;
>> +    nest = nla_nest_start(skb, RTA_ENCAP);
>
> Again, it doesn't look like this will build since RTA_ENCAP isn't 
> added until patch 2.
>
ack, sorry abt the patch ordering. will fix it.

Thanks for the review.
