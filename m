From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp_cubic: faster cube root
Date: Wed, 7 Mar 2007 13:12:46 +0100
Message-ID: <20070307121246.GA7728@one.firstfloor.org>
References: <20070306102941.32471d57@freekitty> <20070306.135834.26100913.davem@davemloft.net> <20070306144706.4585c079@freekitty> <20070306.202052.03980320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, rkuhn@e18.physik.tu-muenchen.de,
	andi@firstfloor.org, dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49120 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbXCGMMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 07:12:48 -0500
Content-Disposition: inline
In-Reply-To: <20070306.202052.03980320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 08:20:52PM -0800, David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 6 Mar 2007 14:47:06 -0800
> 
> > The Newton-Raphson method is quadratically convergent so
> > only a small fixed number of steps are necessary.
> > Therefore it is faster to unroll the loop. Since div64_64 is no longer
> > inline it won't cause code explosion.
> > 
> > Also fixes a bug that can occur if x^2 was bigger than 32 bits.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Applied, thanks Stephen.

Well that still needs the ugly div64_64 function. At least my goal was to 
eliminate that, not make it faster (I don't see any evidence this function 
is particularly performance critical). You prefer to keep div64_64? 

-Andi
