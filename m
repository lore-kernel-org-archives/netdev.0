From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Wed, 30 Jun 2010 13:55:35 -0700
Message-ID: <20100630135535.0e3a5ea1@nehalam>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
	<20100611084854.0680c014@nehalam>
	<20100622.101537.245382806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joakim.tjernlund@transmode.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59718 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab0F3Uzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 16:55:37 -0400
In-Reply-To: <20100622.101537.245382806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jun 2010 10:15:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 11 Jun 2010 08:48:54 -0700
> 
> > The initial problem report was for a management application that used ICMP
> > to check link availability.
> 
> That application is buggy, and even if we apply this patch it will
> only properly function when speaking to systems in a non-default
> configuration.  And, it would be a non-default setting which, by your
> own admission below, cannot function properly in valid interface
> configurations.

It is a remote management system not a local application.
The management system is stupid, but it is hard to argue with
customers that other system is broken. 

> It's easier to fix the app to work in all cases than to add another
> sysctl knob hack for a segment of the world that can't seem to wrap
> their head around the fact that our behavior is valid, specified, and
> an explicit design decision meant to increase the chances of
> successful communication between two systems.
> 
> > The default is disabled to maintain compatibility with previous behavior.
> > This is not recommended for server systems because it makes fail over more
> > difficult, and does not account for configurations where multiple interfaces
> > have the same IP address.
> 
> The fact that the syctl knob, when enabled, can't even function properly
> in this "multiple interfaces with same address" case is another reason I
> have decided to not apply this.

We already have sysctl knobs that exist to work around broken printer TCP,
middleboxes and other broken stacks; my opinion this is just another one
of those types of workarounds.
