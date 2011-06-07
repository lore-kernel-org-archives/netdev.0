From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Use unsigned variables for packet lengths in ip[6]_queue.
Date: Tue, 07 Jun 2011 16:19:08 +0200
Message-ID: <4DEE335C.1010504@trash.net>
References: <20110420014221.GC26949@redhat.com>	<20110419.204105.68144653.davem@davemloft.net>	<20110528003651.GA8380@redhat.com> <20110602.135742.1323883827030625599.davem@davemloft.net> <4DEE209C.2010104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53472 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635Ab1FGOTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 10:19:17 -0400
In-Reply-To: <4DEE209C.2010104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.06.2011 14:59, Patrick McHardy wrote:
> On 02.06.2011 22:57, David Miller wrote:
>> From: Dave Jones <davej@redhat.com>
>> Date: Fri, 27 May 2011 20:36:51 -0400
>>
>>> So I went back to this today, and found something that doesn't look right.
>>> After adding some instrumentation, and re-running my tests, I found that
>>> the reason we were blowing up with enormous allocations was that we
>>> were passing down a nlmsglen's like -1061109568
>>>
>>> Is there any reason for that to be signed ?
>>> The nlmsg_len entry of nlmsghdr is a u32, so I'm assuming this is a bug.
>>>
>>> With the patch below, I haven't been able to reproduce the problem, but
>>> I don't know if I've inadvertantly broken some other behaviour somewhere
>>> deeper in netlink where this is valid.
> 
> This is fine, but I'm wondering whether this can really fix the problem
> you've been seeing. Before the packet is reallocated, the length of
> nlmsglen - NLMSGLEN(0) - sizeof(struct ipq_peer_msg) is compared to
> ipq_peer_msg->data_len, so both values need to be wrong.
> ipq_peer_msg->data_len is a size_t, so it's unsigned.
> 
> I think what we should additionally do is verify that data_len < 65535
> since that's the maximum size of an IP packet.

We're actually already doing this. This makes it even more strange that
you're seeing this problem. Could you send me your testcase?
