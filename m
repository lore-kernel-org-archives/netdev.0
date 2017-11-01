From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2 PATCH 04/11] net: Create and use new helper
 xfrm_dst_child().
Date: Wed, 01 Nov 2017 11:07:35 +0900 (KST)
Message-ID: <20171101.110735.291520563960209347.davem@davemloft.net>
References: <20171031141054.9954-1-davem@davemloft.net>
        <20171031141054.9954-5-davem@davemloft.net>
        <1509475162.3828.31.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:07:40 -0400
In-Reply-To: <1509475162.3828.31.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Oct 2017 11:39:22 -0700

> On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
>> @@ -116,12 +116,14 @@ EXPORT_SYMBOL(dst_alloc);
>>  
>>  struct dst_entry *dst_destroy(struct dst_entry * dst)
>>  {
>> -	struct dst_entry *child;
>> +	struct dst_entry *child = NULL;
>>  
>>  	smp_rmb();
>>  
>> -	child = dst->child;
>> -
>> +#ifdef CONFIG_XFRM
>> +	if (dst->xfrm)
>> +		child = dst->child;
>> +#endif
> 
> 
> Why not using here :
> 
> 	child = xfrm_dst_child(dst);
> 
> This avoid the #ifdef and uses the new helper quite well.

Yep, that makes a lot of sense, thanks for the review(s).
