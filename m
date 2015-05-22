From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 2/2] ip_fragment: don't forward defragmented DF
 packet
Date: Fri, 22 May 2015 16:45:40 +0200
Message-ID: <1432305940.28081.3.camel@stressinduktion.org>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
	 <1432305171-21932-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49998 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756510AbbEVOpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 10:45:42 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 9D4B92067D
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 10:45:41 -0400 (EDT)
In-Reply-To: <1432305171-21932-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2015-05-22 at 16:32 +0200, Florian Westphal wrote:
> We currently always send fragments without DF bit set.
> 
> Thus, given following setup:
> 
> mtu1500 - mtu1500:1400 - mtu1400:1280 - mtu1280
>    A           R1              R2         B
> 
> Where R1 and R2 run linux with netfilter defragmentation/conntrack
> enabled, then if Host A sent a fragmented packet _with_ DF set to B, R1
> will respond with icmp too big error if one of these fragments exceeded
> 1400 bytes.
> 
> However, if R1 receives fragment sizes 1200 and 100, it would
> forward the reassembled packet without refragmenting, i.e.
> R2 will send an icmp error in response to a packet that was never sent,
> citing mtu that the original sender never exceeded.
> 
> The other minor issue is that a refragmentation on R1 will conceal the
> MTU of R2-B since refragmentation does not set DF bit on the fragments.
> 
> This modifies ip_fragment so that we track largest fragment size seen
> both for DF and non-DF packets, and set frag_max_size to the largest
> value.
> 
> If the DF fragment size is larger or equal to the non-df one, we will
> consider the packet a path mtu probe:
> We set DF bit on the reassembled skb and also tag it with a new IPCB flag
> to force refragmentation even if skb fits outdev mtu.
> 
> We will also set DF bit on each fragment in this case.
> 
> Joint work with Hannes Frederic Sowa.
> 
> Reported-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

And also:
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
