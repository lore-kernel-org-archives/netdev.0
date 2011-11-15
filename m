From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 15:26:31 +0800
Message-ID: <4EC21427.9080008@cn.fujitsu.com>
References: <4EBA2E30.8050102@cn.fujitsu.com>	<20111109.155936.1972852290616131285.davem@davemloft.net>	<4EC1FB5D.80705@cn.fujitsu.com> <20111115.013527.2095109012737872896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52927 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752119Ab1KOH0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 02:26:10 -0500
In-Reply-To: <20111115.013527.2095109012737872896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Li Wei <lw@cn.fujitsu.com>
> Date: Tue, 15 Nov 2011 13:40:45 +0800
> 
>> These days i am doing some ICMP tests and sadly found that wen can't update
>> iph->daddr in ip_options_rcv_srr(), It's too early. When some exception
>> ocurred later (eg. in ip_forward() when goto sr_failed) we need the ip header
>> be identical to the original one as ICMP need it.
>>
>> It seems we need rt->rt_dst in ip_forward_options() and ip_forward() instead
>> of iph->daddr.
> 
> An alternative is to store the calculated destination address somewhere
> in the IPCB(skb).
> 
> 

You mean modify struct inet_skb_parm add some field to store the calculated 
destination address?

My question, in ip_forward() and ip_forward_options() rt is there, why not
we just use it?
