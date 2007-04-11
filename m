From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Wed, 11 Apr 2007 22:15:51 +1000
Message-ID: <1176293751.14322.14.camel@localhost.localdomain>
References: <20070411075602.GA17635@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37886 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbXDKMQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 08:16:15 -0400
In-Reply-To: <20070411075602.GA17635@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-11 at 17:56 +1000, Herbert Xu wrote:
> Hi:
> 
> [NET]: Get rid of NETIF_F_INTERNAL_STATS
> 
> The recently added NETIF_F_INTERNAL_STATS isn't very useful.  If the
> device driver needs to set it then it can always override get_stats
> instead.  All existing drivers that have stats (which should be every
> one) will override get_stats anyway.  Those that don't have stats
> (if there are any) wouldn't hurt from having a get_stats that just
> returns zeros everywhere.

Actually, I did this precisely because I really didn't want to start
exposing bogus stats in /proc/net/dev.  An audit might clarify if this
is an actual issue.

> So we can simply get rid of this flag.
> 
> This also fixes a potential crash in those get_stats callers that
> don't check for a NULL return value (e.g., /proc/net/dev).

Hmm, I thought it did that in my original patch?

Rusty.


