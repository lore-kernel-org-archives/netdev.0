From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] fixes to arp_notify for virtual machine migration
 use case
Date: Sun, 23 May 2010 23:37:22 -0700 (PDT)
Message-ID: <20100523.233722.232536798.davem@davemloft.net>
References: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jeremy.fitzhardinge@citrix.com, stable@kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46372
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753851Ab0EXGhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:37:13 -0400
In-Reply-To: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 12 May 2010 14:39:14 +0100

> Ian Campbell (2):
>       arp_notify: generate broadcast ARP reply not request.
>       arp_notify: generate arp_notify event on NETDEV_CHANGE too

I don't agree with these changes.

For the first one, I think the documentation is just wrong and the
code is what expresses the intent.  The idea is not to spam the
world with a broadcast, only interested parties.

Patch #2 I have major issues with, carriers flapping occaisionally is
very common.  I have several interfaces which do this even on lightly
loaded networks.  Iff we decide to do something like this (big "if")
it would need to be rate limited so that it doesn't trigger due to
normal flapping.

If you want your VM networking devices to trigger this event maybe
the best thing to do is to create a special notification which
allows us to prevent from doing this ARP notify for spurious physical
network device carrier flaps.

