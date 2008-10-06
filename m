From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Mon, 6 Oct 2008 19:54:46 +0200
Message-ID: <20081006195446.1dc5a372@speedy>
References: <20081006173024.2741cc01@speedy>
	<48EA369F.3090306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57835 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbYJFRyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 13:54:53 -0400
In-Reply-To: <48EA369F.3090306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Oct 2008 18:02:39 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Propogate MTU changes of underlying device to all related VLAN
> > devices.
> > see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > ---
> > There might be some discussion about whether to preserve MTU changes
> > on the vlan device if done after startup, but this seems like the best,
> > most direct fix.
> 
> Agreed on both points :) But I think having that dicussion would be
> useful since there are some points that make it not so clear cut
> in my opinion:
> 
> - there are multiple virtual drivers depending on configuration of
>    some underlying device and it would be good if this behaviour (MTU)
>    was consistent since its about interaction with the remaining stack.

Increase is also important, there are two common cases. Reducing MTU
because of PPPoe crap, and increasing it because of Jumbo frames.

> - the stack in fact doesn't require us to reduce the MTU of a VLAN
>    device as long as its within the physically possible MTU.

I think it should call change_mtu so userspace gets notified about both
changes.

> - besides MTU, we have UP/DOWN state - currently VLAN devices go
>    down when the lower device goes down, killing all routes, but
>    don't go UP again when the lower device does. Even if they would,
>    most routes can't be reconstructed. The same is true for at
>    least some of the other virtual network devices.
> 
> - some more items that are often initially taken from the real
>    device, but not synced later on include device and broadcast
>    address and some flags (f.i. IFF_NOARP, IFF_BROADCAST).
> 
> I talked about especially the UP/DOWN point with Ben and some other
> people multiple times, but failed to come up with a one-size-fits-all
> behaviour. So maybe we should just add some knob (a device flag or
> something similar) that "binds" things like MTU, UP/DOWN state etc.
> to the lower device. That would also avoid the potential compatibility
> issues.
> 
