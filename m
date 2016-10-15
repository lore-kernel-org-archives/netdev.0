From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: Require exact match for TCP socket lookups if dif
 is l3mdev
Date: Sat, 15 Oct 2016 17:07:53 -0600
Message-ID: <48ba7600-0624-9684-e609-b7a315e03483@cumulusnetworks.com>
References: <1476473359-15422-1-git-send-email-dsa@cumulusnetworks.com>
 <20161015.174654.72392403309705041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35426 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752018AbcJOXH4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 19:07:56 -0400
Received: by mail-it0-f47.google.com with SMTP id 4so21439837itv.0
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 16:07:55 -0700 (PDT)
In-Reply-To: <20161015.174654.72392403309705041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/16 3:46 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Fri, 14 Oct 2016 12:29:19 -0700
> 
>> +/* can not be used in TCP layer after tcp_v6_fill_cb */
>> +static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
>> +{
>> +#if defined(CONFIG_NET_L3_MASTER_DEV)
>> +	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
>> +	    skb_l3mdev_slave(IP6CB(skb)->flags))
>> +		return true;
>> +#endif
>> +	return false;
>> +}
>  ...
>> +static inline bool skb_l3mdev_slave4(u16 flags)
>> +{
>> +	return !!(flags & IPSKB_L3SLAVE);
>> +}
> 
> I think this makes the code confusing.
> 
> Actually it has been from the beginning, because we have a generically
> named "skb_l3mdev_slave()" helper which strictly operates on ipv6
> state.
> 
> Please do something with the naming of these two helpers,
> skb_l3mdev_slave() and skb_l3mdev_slave4(), so that it is clear that
> they are ipv6 and ipv4 specific helpers, respectively.
> 

I believe at netconf someone mentioned it would be a great day when something is done for IPv6 first and IPv4 was a follow on. Here you go. :-)

I can rename the existing one to skb_l3mdev_slave_6 and make the new one skb_l3mdev_slave_4.
