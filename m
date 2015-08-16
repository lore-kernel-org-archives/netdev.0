From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: Updates to netif_index_is_vrf
Date: Sun, 16 Aug 2015 07:34:12 -0600
Message-ID: <55D09154.9030206@cumulusnetworks.com>
References: <1439683793-2999-1-git-send-email-dsa@cumulusnetworks.com> <20150816003926.GA31357@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34867 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbHPNeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 09:34:16 -0400
Received: by pacgr6 with SMTP id gr6so89698022pac.2
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2015 06:34:16 -0700 (PDT)
In-Reply-To: <20150816003926.GA31357@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/15 6:39 PM, Florian Westphal wrote:
> David Ahern <dsa@cumulusnetworks.com> wrote:
>> As Eric noted netif_index_is_vrf is not called with rcu_read_lock held,
>> so use dev_get_by_index instead of dev_get_by_index_rcu.
>>
>> If VRF is not enabled or oif is 0 skip the device lookup.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> Why not
>
>>   static inline bool netif_index_is_vrf(struct net *net, int ifindex)
>>   {
>> -	struct net_device *dev = dev_get_by_index_rcu(net, ifindex);
>>   	bool rc = false;
>>
>> -	if (dev)
>> -		rc = netif_is_vrf(dev);
>> +#if IS_ENABLED(CONFIG_NET_VRF)
>> +	struct net_device *dev;
>> +
>> +	if (ifindex == 0)
>> +		return false;
>
> 	rcu_read_lock();
>
> 	dev = dev_get_by_index_rcu(net, ifindex);
> 	if (dev)
> 		rc = netif_is_vrf(dev);
>
> 	rcu_read_unlock();
>
>> +#endif
>>   	return rc;
>
> instead?

sure. That saves the inc and dec on the refcnt. will respin.

David
