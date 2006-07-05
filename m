From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Wed, 5 Jul 2006 20:57:05 +0200
Message-ID: <200607052057.05526.stefan@loplof.de>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <44AA3DD3.1090106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natlemon.rzone.de ([81.169.145.170]:27054 "EHLO
	natlemon.rzone.de") by vger.kernel.org with ESMTP id S964984AbWGESyU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 14:54:20 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AA3DD3.1090106@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag 04 Juli 2006 12:07 schrieb Patrick McHardy:

> > -	new_dev->state = real_dev->state & VLAN_LINK_STATE_MASK;
> > +	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);

> This introduced a regression by propagating the __LINK_STATE_XOFF flag,
> when the queue of the underlying device is stopped it will be stopped
> for the VLAN device too and never be woken up. Since you changed
> VLAN_LINK_STATE_MASK, I assume the intention was to just add
> __LINK_STATE_DORMANT to the propagated flags and keep using it here?

Hm, I did not hit that bug during tests, even though starfire calls 
netif_stop_queue() on close. But I don't remember whether I tested added 
VLANs while the main interface was ifconfig'ed down.

Anyway, is it good to propagate __LINK_STATE_PRESENT then? The same situation 
here, add a VLAN while the main interface is "not present", and you are out. 
Can you try to revert the quoted part of my patch, I'll rethink which flags 
should be copied on device creation.

Stefan
