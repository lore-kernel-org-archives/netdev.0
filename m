From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 13:40:45 +0800
Message-ID: <4EC1FB5D.80705@cn.fujitsu.com>
References: <4EBA2E30.8050102@cn.fujitsu.com> <20111109.155936.1972852290616131285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53803 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750909Ab1KOFk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 00:40:28 -0500
In-Reply-To: <20111109.155936.1972852290616131285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Li Wei <lw@cn.fujitsu.com>
> Date: Wed, 09 Nov 2011 15:39:28 +0800
> 
>> When opt->srr_is_hit is set skb_rtable(skb) has been updated for
>> 'nexthop' and iph->daddr should always equals to skb_rtable->rt_dst
>> holds, We need update iph->daddr either.
>>
>> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> 
> Applied, thank you.
> 
> 

Hi, David

These days i am doing some ICMP tests and sadly found that wen can't update
iph->daddr in ip_options_rcv_srr(), It's too early. When some exception
ocurred later (eg. in ip_forward() when goto sr_failed) we need the ip header
be identical to the original one as ICMP need it.

It seems we need rt->rt_dst in ip_forward_options() and ip_forward() instead
of iph->daddr.
