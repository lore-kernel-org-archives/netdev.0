From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sun, 25 Mar 2007 17:12:16 +0100
Message-ID: <46069F60.3020501@katalix.com>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <46059EF8.6050603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33543 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695AbXCYQMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 12:12:19 -0400
In-Reply-To: <46059EF8.6050603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> James Chapman wrote:
>> [PPPOL2TP]: Add PPP-over-L2TP driver core.
> 
> A couple more comments:
> 
> - seq_file handling doesn't check seq_printf return values 

ack

>   and
>   tries to dump the entire hash table at once, which might
>   exceed the available room.

I thought seq_printf handled large output (multiple pages)? I am aware 
of the page size limitation of raw proc handlers.

> - there appear to be no checks for duplicate session IDs on
>   session creation.
> - try_module_get/put_module in pppol2tp_create look unnecessary
> - kfree can take NULL pointers
> - direct dereference of user pointer in pppol2tp_sendmsg debugging
> - jiffies.h includes conversion functions for HZ <-> msecs

all acked

> - Any particular reason why the SKB_CB is put after inet_skb_parm?
>   On 64 bit this almost reaches the limit, might be safer to put
>   it at the beginning.

A long time ago (early 2.6.9-ish?) I had problems with some netfilter 
setups when I overwrote inet_skb_parm. I'll investigate further.

Thanks for your comments - they're very useful.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

