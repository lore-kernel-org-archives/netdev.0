From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 7/9] net: ipmr: remove SLAB_PANIC
Date: Sat, 21 Nov 2015 15:27:03 +0100
Message-ID: <56507F37.8070708@cumulusnetworks.com>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
 <1448110902-28793-8-git-send-email-razor@blackwall.org>
 <1448115813.22599.289.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:32790 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932227AbbKUO1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 09:27:06 -0500
Received: by wmec201 with SMTP id c201so107073419wme.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 06:27:05 -0800 (PST)
In-Reply-To: <1448115813.22599.289.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2015 03:23 PM, Eric Dumazet wrote:
> On Sat, 2015-11-21 at 14:01 +0100, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> It's not necessary to panic upon allocation failure, returning an error
>> at that point is okay because user-space won't be able to use any of the
>> ops since they didn't get registered and the default table is null.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>>  net/ipv4/ipmr.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> index a006d96d6cd9..2c7fa584a274 100644
>> --- a/net/ipv4/ipmr.c
>> +++ b/net/ipv4/ipmr.c
>> @@ -2675,7 +2675,7 @@ int __init ip_mr_init(void)
>>  
>>  	mrt_cachep = kmem_cache_create("ip_mrt_cache",
>>  				       sizeof(struct mfc_cache),
>> -				       0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
>> +				       0, SLAB_HWCACHE_ALIGN,
>>  				       NULL);
>>  	if (!mrt_cachep)
>>  		return -ENOMEM;
> 
> This runs at boot time.
> 
> I very much prefer a panic instead of having to deal with a host with a
> probable bug in mm layer at this point.
> 
Right, I was unsure about this one, I tried to rely on the ipmr_get_table() returning NULL but
I guess it's better to be safe than sorry.
I'll respin with the panic in place and removed null check.

> For IPv6, it is a different matter as it might be a module, thus
> ip6_mr_init() does not use SLAB_PANIC
Yep, I saw. It wasn't the reason I removed this one.

Thanks for the review!
