From: David Miller <davem@davemloft.net>
Subject: Re: [net-next fragmentation icmp v4 3/4] bridge_netfilter: No ICMP
 packet on IPv4 defragmentation timeout
Date: Thu, 14 May 2015 17:42:49 -0400 (EDT)
Message-ID: <20150514.174249.797773651224323358.davem@davemloft.net>
References: <1431570482-9236-4-git-send-email-azhou@nicira.com>
	<20150514085940.GD6179@breakpoint.cc>
	<CACzMAJ+J3QGFZa976_M=_ZKjgEPiJszyYrqeqeGj=9rjCBZJ7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161034AbbENVmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:42:51 -0400
In-Reply-To: <CACzMAJ+J3QGFZa976_M=_ZKjgEPiJszyYrqeqeGj=9rjCBZJ7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Thu, 14 May 2015 12:54:23 -0700

> On Thu, May 14, 2015 at 1:59 AM, Florian Westphal <fw@strlen.de> wrote:
>> Andy Zhou <azhou@nicira.com> wrote:
>>> Currently, on defragmentation timeout error, ICMP error message
>>> will be generated. This is fine when they are used in a routing context,
>>> but does not make sense in the context of bridging netfilter.
>>>
>>> This patch adds a bit (IPSKB_NO_FRAG_ICMP) in IPCB to control
>>> whether ICMP error message should be generated. br_netfiler sets
>>> this bit.
>>
>> Could you please explain why we need this patch?
>> After the previous change (patch 2 in your series), we will already
>> bail out before hitting
>>
>> /* Send an ICMP "Fragment Reassembly Timeout" message. */
>> icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
>>
>> in ip_expire() based on qp->user value test?
> 
> Letting caller making the decision seems to be a better design choice
> rather than implicit
> logic embedded within the function.  It is also more flexible and
> robust when we need to extend 'user'
> range down the road.

You're doing useless testing for a hypothetical situation which may
never come to fruitation at all.

I don't think that ever qualifies as a legitimate objection.
