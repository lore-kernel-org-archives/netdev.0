From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_packet: relax BUG statement in
 tpacket_destruct_skb
Date: Fri, 10 Aug 2012 16:54:50 -0700 (PDT)
Message-ID: <20120810.165450.638010040921216276.davem@davemloft.net>
References: <1344530345.28842.11.camel@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760187Ab2HJXyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 19:54:50 -0400
In-Reply-To: <1344530345.28842.11.camel@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Thu, 09 Aug 2012 18:39:05 +0200

> Here's a quote of the comment about the BUG macro from asm-generic/bug.h:
> 
>  Don't use BUG() or BUG_ON() unless there's really no way out; one
>  example might be detecting data structure corruption in the middle
>  of an operation that can't be backed out of.  If the (sub)system
>  can somehow continue operating, perhaps with reduced functionality,
>  it's probably not BUG-worthy.
> 
>  If you're tempted to BUG(), think again:  is completely giving up
>  really the *only* solution?  There are usually better options, where
>  users don't need to reboot ASAP and can mostly shut down cleanly.
> 
> In our case, the status flag of a ring buffer slot is managed from both sides,
> the kernel space and the user space. This means that even though the kernel
> side might work as expected, the user space screws up and changes this flag
> right between the send(2) is triggered when the flag is changed to
> TP_STATUS_SENDING and a given skb is destructed after some time. Then, this
> will hit the BUG macro. Instead, we relax this condition with a WARN_ON_ONCE
> macro, so that the user is aware of this situation. I've tested it and the
> system still behaves /stable/, so in accordance with the above comment, we
> should rather relax this behavior with a warning.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

I would like this check to simply be deleted completely.

As you said, it's a user changable value, therefore we cannot use it
for kernel side internal consistency checks at all.
