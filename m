From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code
 (v2).
Date: Wed, 02 Apr 2008 00:06:29 -0700 (PDT)
Message-ID: <20080402.000629.39145635.davem@davemloft.net>
References: <47EA1694.1080208@openvz.org>
	<20080401121532.GA24470@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, den@openvz.org, netdev@vger.kernel.org,
	devel@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41860
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751628AbYDBHG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:06:29 -0400
In-Reply-To: <20080401121532.GA24470@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 1 Apr 2008 20:15:32 +0800

> On Wed, Mar 26, 2008 at 12:25:40PM +0300, Pavel Emelyanov wrote:
> > Commit 8b7817f3a959ed99d7443afc12f78a7e1fcc2063 ([IPSEC]: Add ICMP host
> > relookup support) introduced some dst leaks on error paths: the rt
> > pointer can be forgotten to be put. Fix it bu going to a proper label.
> 
> I just remembered that we have exactly the same code path in IPv6
> and sure enough it also has the same bug.
> 
> [IPV6]: Fix ICMP relookup error path dst leak
> 
> When we encounter an error while looking up the dst the second
> time we need to drop the first dst.  This patch is pretty much
> the same as the one for IPv4.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks for catching this.
