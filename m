From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 18:32:36 +0800
Message-ID: <4EF30744.6000509@linux.vnet.ibm.com>
References: <4EF1B0D9.2010007@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:33012 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab1LVKcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 05:32:50 -0500
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Thu, 22 Dec 2011 16:02:46 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBMAWf0m1753218
	for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 16:02:41 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBMAWd4X029383
	for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 21:32:41 +1100
In-Reply-To: <4EF1B0D9.2010007@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2011 06:11 PM, Michal Simek wrote:

> Hi Eric and David,
> 
> I have found one problem with ll_temac driver and
> this commit: net: more accurate skb truesize
> sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
> 
> The problem is only with icmp packets from the target. It is sent and
> driver receive it
> but it is not proceed to the application.
> 

Hi, Michal

What's the type of icmp you are using? such as "EchoReps", we can find
the actually handler routine by this type.

And you said the packet already received by driver, can you tell me the
way you used to confirm this?

And have you checked when was the icmp packet being dropped, is it in
icmp_rcv or before or later?

Thanks,
Michael Wang

> The problem I see is that kmalloc_node_track_caller allocate
> specific size and then this size is changed by
> SKB_WITH_OVERHEAD(ksize(data)).
> The problem is with netdev_alloc_skb_ip_align which calls __alloc_skb
> function.
> 
> Currently driver uses setting for jumbo frames (9k). When I change it to
> use mtu (1,5k) then
> everything is ok.
> 
> Can you give me some hints what can be wrong?
> 
> Thanks,
> Michal
> 
> 
