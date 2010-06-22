From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Tue, 22 Jun 2010 10:15:37 -0700 (PDT)
Message-ID: <20100622.101537.245382806.davem@davemloft.net>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
	<20100611084854.0680c014@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joakim.tjernlund@transmode.se, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58669
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756498Ab0FVRPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:15:25 -0400
In-Reply-To: <20100611084854.0680c014@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 11 Jun 2010 08:48:54 -0700

> The initial problem report was for a management application that used ICMP
> to check link availability.

That application is buggy, and even if we apply this patch it will
only properly function when speaking to systems in a non-default
configuration.  And, it would be a non-default setting which, by your
own admission below, cannot function properly in valid interface
configurations.

It's easier to fix the app to work in all cases than to add another
sysctl knob hack for a segment of the world that can't seem to wrap
their head around the fact that our behavior is valid, specified, and
an explicit design decision meant to increase the chances of
successful communication between two systems.

> The default is disabled to maintain compatibility with previous behavior.
> This is not recommended for server systems because it makes fail over more
> difficult, and does not account for configurations where multiple interfaces
> have the same IP address.

The fact that the syctl knob, when enabled, can't even function properly
in this "multiple interfaces with same address" case is another reason I
have decided to not apply this.
