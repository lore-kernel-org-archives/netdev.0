From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 10/11][INET] Eliminate difference in actions
 of sysctl and proc handler for conf.all.forwarding
Date: Wed, 05 Dec 2007 21:39:33 -0800 (PST)
Message-ID: <20071205.213933.40987728.davem@davemloft.net>
References: <20071205.020645.171664472.davem@davemloft.net>
	<E1J04N1-0006uU-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49224
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752073AbXLFFje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:39:34 -0500
In-Reply-To: <E1J04N1-0006uU-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 06 Dec 2007 11:13:39 +1100

> David Miller <davem@davemloft.net> wrote:
> >
> > The user is pretty much screwed in one way or the other.
> > For example:
> > 
> > 1) If 'default' propagates to all devices, any specific
> >   setting for a device is lost.
> > 
> > 2) If 'default' does not propagate, there is no way to
> >   have 'default' influence devices which have already
> >   been loaded.
> 
> Well the way it works on IPv4 currently (for most options) is
> that we'll propagate default settings to a device until either:
> 
> 1) the user modifies the setting for that device;
> 2) or that an IPv4 address has been added to the device.
> 
> 2) was done to preserve backwards compatibility as the controls
> were previously only available after address addition and we did
> not propagate default settings in that case..
> 
> We could easily extend this so that the default propagation
> worked until the user modified the setting, with an ioctl to
> revert to the current behaviour for compatibility.

Ok, this sounds like a good idea.

But we go back again to the question of how to get this "current
behavior" setting instantiated early enough.  So much stuff happens
via initrd's etc. before the real userland has a change to run things,
read setting from the real filesystem config giles, in order to change
this.
