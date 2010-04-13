From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 7/9] ipv4: ipmr: convert struct mfc_cache to struct
 list_head
Date: Tue, 13 Apr 2010 13:18:26 +0200
Message-ID: <4BC45302.7080004@trash.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>	<1271007435-20035-8-git-send-email-kaber@trash.net> <20100413.041506.177518126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47377 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab0DMLS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:18:28 -0400
In-Reply-To: <20100413.041506.177518126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: kaber@trash.net
> Date: Sun, 11 Apr 2010 19:37:13 +0200
> 
>> From: Patrick McHardy <kaber@trash.net>
>>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Great, it looks like you didn't fall into most of the
> traps that usually occur during a list_head conversion :-)
> 
> But:
> 
>> -		c->next = net->ipv4.mfc_unres_queue;
>> -		net->ipv4.mfc_unres_queue = c;
>> +		list_add_tail(&c->list, &net->ipv4.mfc_unres_queue);
>  ...
>>  	write_lock_bh(&mrt_lock);
>> -	c->next = net->ipv4.mfc_cache_array[line];
>> -	net->ipv4.mfc_cache_array[line] = c;
>> +	list_add_tail(&c->list, &net->ipv4.mfc_cache_array[line]);
>>  	write_unlock_bh(&mrt_lock);
> 
> Are you sure we mean to insert to the tail here?  It looks like a head
> insertion to me beforehand, and the fact that the previous list
> iterators start at the list head pointer seem to confirm this.

I don't think it matters since each entry only exists once and
there are no ordering requirements, but I'll change it just to
make sure.

Thanks for your review so far :)
