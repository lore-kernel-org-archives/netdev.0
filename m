From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] napi_synchronize: waiting for NAPI
Date: Wed, 17 Oct 2007 18:26:28 -0700
Message-ID: <20071017182628.6590fcdd@freepuppy.rosehill>
References: <20071017202640.171902388@linux-foundation.org>
	<20071017202653.266566036@linux-foundation.org>
	<1192667289.12879.0.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35723 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758604AbXJRB3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 21:29:17 -0400
In-Reply-To: <1192667289.12879.0.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 10:28:09 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Wed, 2007-10-17 at 13:26 -0700, Stephen Hemminger wrote:
> > plain text document attachment (napi-synchronize.patch)
> > Some drivers with shared NAPI need a synchronization barrier.
> > Also suggested by Benjamin Herrenschmidt for EMAC.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Just saw this patch, sorry, missed it. Same as you sent me on another
> reply, I still think it needs the smp barrier. Can you have a look at
> the one I posted today ?
> 
> Cheers,
> Ben.

Could you give a concrete example as to why it needs a smp barrier?
The test_bit is going to get a consistent result. Are you worried about
operations ordering before the test_bit()? In that case, one of those
smp_mb__before_xxx functions is probably what is needed.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
