From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 19:57:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004201947470.29017@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1004201834190.29017@hs20-bc2-1.build.redhat.com>
 <20100420.164505.34362726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab0DTX54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 19:57:56 -0400
In-Reply-To: <20100420.164505.34362726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Apr 2010, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Tue, 20 Apr 2010 19:40:56 -0400 (EDT)
> 
> > Reviewing the code further, I found one very weird commit
> > 572a9d7b6fc7f20f573664063324c086be310c42 committed to 2.6.33. What
> > it does, it changes the semantics of ndo_hard_start_xmit(). Prior to
> > the patch, the meaning was --- return zero (NETDEV_TX_OK) --- the
> > skb is consumed by the driver. Returns non-zero --- the skb is left
> > owned by the caller.  The patch changes it to return other flags in
> > bits 4-7 and changes the consumed/returned logic.
> > 
> > The problem is that there is still plenty of code that compares it
> > against NETDEV_TX_OK to find out if the skb was consumed.
> 
> Drivers are not supposed to return those new flag bits, the new flag
> bits as return values exist only in the packet scheduler path.

If they are not supposed to return it, why do you test it in 
dev_hard_start_xmit?

Define clearly what the return status is allowed (and maybe enforce it 
with BUG()s) and follow that definition.

Currently, there is no specification and the code is unintelligible crap: 
it first masks the value with ~0xf0 to test if the skb is consumed 
(dev_hard_start_xmit) and then compares it with 0x0f for the same test 
(dev_queue_xmit).

> We're not reverting the commit you mention, we're going to fix
> whatever bug exists instead.

So have a fun searching for them :-/

Mikulas
