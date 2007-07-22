From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 18:59:05 -0700 (PDT)
Message-ID: <20070721.185905.18310463.davem@davemloft.net>
References: <1185004811.6344.37.camel@localhost.localdomain>
	<20070721.115428.48807536.davem@davemloft.net>
	<1185059423.6344.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbXGVB7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 21:59:06 -0400
In-Reply-To: <1185059423.6344.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sun, 22 Jul 2007 09:10:23 +1000

> In five years' time, the "napi_struct for simple drivers" in net_device
> will look confusing.  Since your change touches all NAPI drivers anyway,
> it'd be nice to go straight to "everyone allocates their own NAPI
> struct" in one jump.

Good point.

But note that you'd be adding a pointer deref, the current sequence:

napi_struct --> netdev --> driver_private

involves all pointer arithmetic and no derefs, whereas:

napi_struct --> driver_private --> netdev

will involve at least on deref to get to the netdev from the
driver_private.

(Ignore the fact that netdev_priv() is not currently optimized
 as it used to be, that's an abberation of the current multi-queue
 implementation and will be fixed).

So this suggestion does have real downsides.
