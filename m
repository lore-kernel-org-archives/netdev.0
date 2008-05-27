From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 18:33:55 +0300
Message-ID: <200805271833.55880.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527151259.GA11862@2ka.mipt.ru> <20080527152234.GA16419@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2483 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758217AbYE0PfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 11:35:04 -0400
In-Reply-To: <20080527152234.GA16419@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2008, Evgeniy Polyakov wrote:
>
> The same wrong one, sorry about that.
>
> Idea is to hold skb between release/lock sock calls and thus do not
> allow to free it by core stack when it is being released. Patch still
> misses the case, when socket is released and skb was dequeued, so splice
> will try to dequeue it again, which will crash. I will think on how to
> fix the issue.


Yes, I think I got the idea you are trying to use here. But, somehow I feel 
uneasy with this approach :) Isn't it cleaner to keep the lock and try to 
avoid the deadlock on the sendfile() side? Or is that unfeasible?

I don't think we can drop the socket lock, it will introduce at least on type 
of races: since the skb we are processing is still on the socket queue, any 
entity accessing the socket queue will possible collide with us. 

Thanks,
tavi
