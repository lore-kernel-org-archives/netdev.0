From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net/ehea: use consistent type
Date: Wed, 31 Dec 2008 20:09:01 +1100
Message-ID: <1230714541.15389.69.camel@pasglop>
References: <20081231141730.81449124.sfr@canb.auug.org.au>
	 <20081230.215101.228854586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, tklein@de.ibm.com, netdev@vger.kernel.org,
	raisch@de.ibm.com, themann@de.ibm.com, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43311 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296AbYLaJJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2008 04:09:48 -0500
In-Reply-To: <20081230.215101.228854586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-30 at 21:51 -0800, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 31 Dec 2008 14:17:30 +1100
> 
> > ehea_plpar_hcall9() takes an unsigned long array, so pass that.
> > 
> > This change will avoid some warnings when we change u64 to unsigned
> > long long.
> > 
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> Patch rejected, for the same reasons as the other driver
> change.
> 
> We're not going to poop up some drivers with the assumption that long
> is 64-bit.

Well, in that case, this patch is actually correct without considering
the u64 change. The array is what lands in the registers of the pHyp
call, so strictly speaking, it's an array of unsigned long's (ie, 32-bit
on a 32-bit platform, 64-bit on a 64-bit platform), not an array of
u64's. This function being a wrapper on that pHyp call, it may as well
use the right type.

Cheers,
Ben.





