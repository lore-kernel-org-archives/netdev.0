From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Sat, 20 Jun 2009 16:47:48 -0700 (PDT)
Message-ID: <20090620.164748.227654288.davem@davemloft.net>
References: <20090619171814.GE18237@hmsreliant.think-freely.org>
	<4A3CD7EC.2040904@gmail.com>
	<4A3D10BD.3050301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, mbizon@freebox.fr,
	dada1@cosmosbay.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40693
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751762AbZFTXro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 19:47:44 -0400
In-Reply-To: <4A3D10BD.3050301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 20 Jun 2009 18:39:25 +0200

> Jarek Poplawski wrote, On 06/20/2009 02:37 PM:
> 
>> Neil Horman wrote, On 06/19/2009 07:18 PM:
>> 
>>> Don't drop route if we're not caching	
> 
> ...
> 
>>>  route.c |   14 ++++++++++++--
>>>  1 file changed, 12 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>> index cd76b3c..65b3a8b 100644
>>> --- a/net/ipv4/route.c
>>> +++ b/net/ipv4/route.c
>>> @@ -1085,8 +1085,16 @@ restart:
>>>  	now = jiffies;
>>>  
>>>  	if (!rt_caching(dev_net(rt->u.dst.dev))) {
>>> -		rt_drop(rt);
> 
> 
> One more question: if this rt is assigned to an skb, there is only
> skb_dst_drop() in kfree_skb(), but it seems we skip rt_free() part,
> or I miss something?

This whole code path was buggy, if it returns success it should
do as the normal success code path does which is assign for
non-SKB case to *rp, or skb_dst_set().
