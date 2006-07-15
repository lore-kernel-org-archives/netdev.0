From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: [PATCH] Fix slab corruption with netem
Date: Sat, 15 Jul 2006 18:06:16 +0200
Message-ID: <44B91278.7010002@yahoo.fr>
References: <44B8395A.1050602@yahoo.fr> <44B90E8C.5090400@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:27601 "EHLO smtp6-g19.free.fr")
	by vger.kernel.org with ESMTP id S1750718AbWGOQFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 12:05:12 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <44B90E8C.5090400@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote :
>> -    struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
>> +    /* We don't fill cb now as skb_unshare() may invalidate it */
>> +    struct netem_skb_cb *cb = NULL;
>>   
> Would rather leave it unitialized, rather than setting to NULL.

I find that strange. If someone mistakenly uses cb before it is 
initialized it could be hard
to figure out why some memory is corrupted. But by initializing cb to 
NULL, it will
always trigger an Oops, so it will be easier to debug in this case.

Cheers.

-- 
Guillaume

