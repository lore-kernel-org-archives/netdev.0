From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_packet: remove BUG statement in
 tpacket_destruct_skb
Date: Sun, 12 Aug 2012 13:42:31 -0700 (PDT)
Message-ID: <20120812.134231.2073879653802622537.davem@davemloft.net>
References: <1344674934.16015.3.camel@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab2HLUmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 16:42:32 -0400
In-Reply-To: <1344674934.16015.3.camel@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Sat, 11 Aug 2012 10:48:54 +0200

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
> will hit the BUG macro. As David suggested, the best solution is to simply
> remove this statement since it cannot be used for kernel side internal
> consistency checks. I've tested it and the system still behaves /stable/ in
> this case, so in accordance with the above comment, we should rather remove it.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Applied.
