From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Fix slab corruption with netem
Date: Sat, 15 Jul 2006 16:34:10 -0700
Message-ID: <44B97B72.5010301@osdl.org>
References: <44B8395A.1050602@yahoo.fr> <44B90E8C.5090400@osdl.org> <44B91278.7010002@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37031 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964809AbWGOXeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 19:34:16 -0400
To: Guillaume Chazarain <guichaz@yahoo.fr>
In-Reply-To: <44B91278.7010002@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guillaume Chazarain wrote:
> Stephen Hemminger wrote :
>>> -    struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
>>> +    /* We don't fill cb now as skb_unshare() may invalidate it */
>>> +    struct netem_skb_cb *cb = NULL;
>>>   
>> Would rather leave it unitialized, rather than setting to NULL.
>
> I find that strange. If someone mistakenly uses cb before it is 
> initialized it could be hard
> to figure out why some memory is corrupted. But by initializing cb to 
> NULL, it will
> always trigger an Oops, so it will be easier to debug in this case.
>
> Cheers.
>
Gcc will complain if variable is used before initialized, and I would 
rather see it at compile time than runtime.
