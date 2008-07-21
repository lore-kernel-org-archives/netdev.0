From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Make simple TX hash little endian safe.
Date: Mon, 21 Jul 2008 19:20:01 +0200
Message-ID: <20080721172001.GD29543@basil.nowhere.org>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org> <20080721.094433.235903960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:16509 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbYGURUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 13:20:53 -0400
Content-Disposition: inline
In-Reply-To: <20080721.094433.235903960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 09:44:33AM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon, 21 Jul 2008 10:48:07 +0200
> 
> > Currently it will not use the lower
> > bits at all on big endian system, mapping e.g. all connections to a single
> > queue on a local network which only differs in the low bits.
> > 
> > Also fold the upper 16 bits always in the lower 16bits.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> I plan to make this use jhash plus a reciprocol multiply
> to fix the hash effectiveness as well as get rid of the
> modulus and make the hash not attackable.

Ok makes sense to use jhash and also the multiplication.

Hmm but randomizations means it won't be stable on benchmarks, will it?
Is attacking such a hash really a problem? Having stable performance
on benchmarks might be preferable.

The other thing (one of my favourite pet peeves) is that
get_random_bytes() on reasonably early kernel boot
is not very random because there will be hardly any entropy in the pool.
So I'm not sure it is actually particularly non predictible,
at least on systems who transmit packets early.

-Andi

