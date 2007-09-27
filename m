From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] Make TCP prequeue configurable
Date: Thu, 27 Sep 2007 15:44:32 -0700
Message-ID: <20070927154432.6ca3b525@freepuppy.rosehill>
References: <46FC29E1.9010809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34542 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752643AbXI0Wpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 18:45:50 -0400
In-Reply-To: <46FC29E1.9010809@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 00:08:33 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Hi all
> 
> I am sure some of you are going to tell me that prequeue is not
> all black :)
> 
> Thank you
> 
> [RFC] Make TCP prequeue configurable
> 
> The TCP prequeue thing is based on old facts, and has drawbacks.
> 
> 1) It adds 48 bytes per 'struct tcp_sock'
> 2) It adds some ugly code in hot paths
> 3) It has a small hit ratio on typical servers using many sockets
> 4) It may have a high hit ratio on UP machines running one process,
>     where the prequeue adds litle gain. (In fact, letting the user
>     doing the copy after being woke up is better for cache reuse)
> 5) Doing a copy to user in softirq handler is not good, because of
>     potential page faults :(
> 6) Maybe the NET_DMA thing is the only thing that might need prequeue.
> 
> This patch introduces a CONFIG_TCP_PREQUEUE, automatically selected if 
> CONFIG_NET_DMA is on.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 

Rather than having a two more compile cases and test cases to deal
with.  If you can prove it is useless, make a case for killing
it completely.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
