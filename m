From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Mon, 06 Oct 2008 18:02:39 +0200
Message-ID: <48EA369F.3090306@trash.net>
References: <20081006173024.2741cc01@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45496 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbYJFQCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 12:02:47 -0400
In-Reply-To: <20081006173024.2741cc01@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Propogate MTU changes of underlying device to all related VLAN
> devices.
> see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> There might be some discussion about whether to preserve MTU changes
> on the vlan device if done after startup, but this seems like the best,
> most direct fix.

Agreed on both points :) But I think having that dicussion would be
useful since there are some points that make it not so clear cut
in my opinion:

- there are multiple virtual drivers depending on configuration of
   some underlying device and it would be good if this behaviour (MTU)
   was consistent since its about interaction with the remaining stack.

- the stack in fact doesn't require us to reduce the MTU of a VLAN
   device as long as its within the physically possible MTU.

- besides MTU, we have UP/DOWN state - currently VLAN devices go
   down when the lower device goes down, killing all routes, but
   don't go UP again when the lower device does. Even if they would,
   most routes can't be reconstructed. The same is true for at
   least some of the other virtual network devices.

- some more items that are often initially taken from the real
   device, but not synced later on include device and broadcast
   address and some flags (f.i. IFF_NOARP, IFF_BROADCAST).

I talked about especially the UP/DOWN point with Ben and some other
people multiple times, but failed to come up with a one-size-fits-all
behaviour. So maybe we should just add some knob (a device flag or
something similar) that "binds" things like MTU, UP/DOWN state etc.
to the lower device. That would also avoid the potential compatibility
issues.

