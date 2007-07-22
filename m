From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sun, 22 Jul 2007 12:39:32 +1000
Message-ID: <1185071972.6344.61.camel@localhost.localdomain>
References: <1185004811.6344.37.camel@localhost.localdomain>
	 <20070721.115428.48807536.davem@davemloft.net>
	 <1185059423.6344.53.camel@localhost.localdomain>
	 <20070721.185905.18310463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41692 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393AbXGVCjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 22:39:52 -0400
In-Reply-To: <20070721.185905.18310463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-07-21 at 18:59 -0700, David Miller wrote:
> But note that you'd be adding a pointer deref, the current sequence:
> 
> napi_struct --> netdev --> driver_private
> 
> involves all pointer arithmetic and no derefs, whereas:
> 
> napi_struct --> driver_private --> netdev
> 
> will involve at least on deref to get to the netdev from the
> driver_private.
> 
> (Ignore the fact that netdev_priv() is not currently optimized
>  as it used to be, that's an abberation of the current multi-queue
>  implementation and will be fixed).
> 
> So this suggestion does have real downsides.

But if netdev -> driver_private can be optimized, so can driver_private
-> netdev.  We just don't have a wrapper for it.  netdev_of() perhaps?

(If it can't be implemented by ptr arith, we have to do some allocation
tricks to hide the dev ptr before driver_private, but it's still
implementable).

Perhaps we should do this anyway: it's another "every driver wants it"
kind of deal AFAICT...

Cheers,
Rusty.


