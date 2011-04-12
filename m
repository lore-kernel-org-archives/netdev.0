From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 00:17:40 -0500
Message-ID: <4DA3E074.5090603@scotdoyle.com>
References: <4D9E62D9.5010400@scotdoyle.com>	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop> <1302582172.3603.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:49335 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1DLFRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 01:17:42 -0400
In-Reply-To: <1302582172.3603.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2011 11:22 PM, Eric Dumazet wrote:
> Also, I would first check if skb->dst already set to not leak a dst
>
> if (!skb->dst) {
> 	rt = bridge_parent_rtable(dev);
> 	if (!rt) {
> 		kfree_skb(skb);
> 		return 0;
> 	}
> 	skb_dst_set_noref(skb,&rt->dst);
> }

Thank you for the idea. Here is the compiler output referring to the 
first line above.

net/bridge/br_netfilter.c: In function 'br_parse_ip_options':
net/bridge/br_netfilter.c:260:10: error: 'struct sk_buff' has no member 
named 'dst'

