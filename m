From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix a potential use after free in sit.c
Date: Sat, 18 Oct 2014 13:07:20 -0400 (EDT)
Message-ID: <20141018.130720.448065424567018228.davem@davemloft.net>
References: <1413624818-20804-1-git-send-email-roy.qing.li@gmail.com>
	<1413647540.27176.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org,
	ghorbel@pivasoftware.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbaJRRHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:07:22 -0400
In-Reply-To: <1413647540.27176.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 18 Oct 2014 08:52:20 -0700

> On Sat, 2014-10-18 at 17:33 +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> pskb_may_pull() maybe change skb->data and make iph pointer oboslete,
>> fix it by geting ip header length directly.
>> 
>> Fixes: ca15a078 (sit: generate icmpv6 error when receiving icmpv4 error)
>> Cc: Oussama Ghorbel <ghorbel@pivasoftware.com>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  net/ipv6/sit.c |    6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks for doing all these checks !

Indeed, I wish we could somehow automate this.

Yes, I'm sure we could construct some sparse et al. rules but
I mean at run time.  For example, having a special pointer type
that you can't dereference directly.  At the time of assignment
the pointer gets some kind of state, and pskb_may_pull() et al.
calls invalidate that "state".

It probably could just be a 2-bit counter which is incremented
every time skb->data is reallocated.

The captured 2-bit generation count could be stored in the low
bits of the pointer.

Anyways, just throwing out ideas...
