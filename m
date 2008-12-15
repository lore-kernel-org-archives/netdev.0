From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [irda-users] [RFC PATCH 0/9] IrDA 2.6.28 bug fix
Date: Mon, 15 Dec 2008 13:31:44 +0100
Message-ID: <20081215123144.GC4017@sortiz.org>
References: <20081215015729.587697008@sortiz.org> <20081214.230837.169487041.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.mail-out.ovh.net ([91.121.26.226]:51116 "HELO
	2.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750761AbYLOMf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 07:35:56 -0500
Content-Disposition: inline
In-Reply-To: <20081214.230837.169487041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Sun, Dec 14, 2008 at 11:08:37PM -0800, David Miller wrote:
> From: Samuel Ortiz <samuel@sortiz.org>
> Date: Mon, 15 Dec 2008 02:57:29 +0100
> 
> > This is a 9 patches series for IrDA, against your net-2.6 tree.
> > This is an attempt to fix kernel.bugzilla.org bug #11795, where we noticed
> > skb->cb could be altered once submitted to dev_queue_xmit. Since IrDA is using
> > this callback to pass per-skb information, we are now stuffing it in front of
> > skb->data, after allocating the right headroom.
> > 
> > Another solution would be to play with the IrDA physical header and skb_pull
> > our skbs whenever we are physically transmitting the data.
> 
> Hi Sam.
> 
> I appreciate you working on this.
> 
> But I there are two issues here:
> 
> 1) There is no way I can put a series of 9 invasive patches like these
>    so late into 2.6.28
> 
>    If we need to fix it in 2.6.28 it'd need to be a 5 to 10 line
>    change at most, even if hackish, before I could seriously consider
>    it.
Ok, I understand. Sorry for not being faster at tackling that bug.
Regarding hackish fixes, would something like commit
f7cd168645dda3e9067f24fabbfa787f9a237488 (see
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=f7cd168645dda3e9067f24fabbfa787f9a237488 )
be acceptable to you as a short term solution ?

 
> 2) Just like you can't claim ownership to skb->cb after dev_queue_xmit(),
>    you just as equally can't claim ownership to areas in front of
>    skb->data either.
> 
> I'm pretty sure we discussed how #2 wouldn't work for this problem.
> 
> I understand you need a way to pass information, but you're trying to
> do it using things the IRDA (nor any other) stack does not own across
> a dev_queue_xmit() invocation.
> 
> Furthermore, device layer schemes that try to use some shared
> part of the skb for their communication is frail, and a good
> way to see how frail it is is to consider how encapsulation of
> such device types within themselves might be made to work.
>
> You can't do it with skb->cb[] private storage, and you doubly can't
> do it by sneaking things in front of skb->data because that's where
> the encapsulated protocol headers would go.
Ok, so I guess I really have to work on passing that meta information along
with the actual data. I tried to avoid this as a lot of code on the IrDA stack
is accessing the IrLAP payload directly. I guess this is the right opportunity
to add proper IrDA accessors, and then stuff the IrDA cb in the actual data
header.
That's obviously -next material though...

Thanks a lot for the feedback.

Cheers,
Samuel.

