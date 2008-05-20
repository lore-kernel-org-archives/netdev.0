From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Use the correct ip_local_out function
Date: Tue, 20 May 2008 14:32:38 -0700 (PDT)
Message-ID: <20080520.143238.87085088.davem@davemloft.net>
References: <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl>
	<BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl>
	<20080520092511.GA9005@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43358
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758213AbYETVcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:32:43 -0400
In-Reply-To: <20080520092511.GA9005@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 May 2008 17:25:11 +0800

> On Wed, May 14, 2008 at 10:19:57AM +0200, Marco Berizzi wrote:
> > 
> > I hope this helps.
> 
> OK found the problem, it was my fault after all :)
> 
> Dave, this patch needs to go into stable too.
> 
> [IPSEC]: Use the correct ip_local_out function
> 
> Because the IPsec output function xfrm_output_resume does its
> own dst_output call it should always call __ip_local_output
> instead of ip_local_output as the latter may invoke dst_output
> directly.  Otherwise the return values from nf_hook and dst_output
> may clash as they both use the value 1 but for different purposes.
> 
> When that clash occurs this can cause a packet to be used after
> it has been freed which usually leads to a crash.  Because the
> offending value is only returned from dst_output with qdiscs
> such as HTB, this bug is normally not visible.
> 
> Thanks to Marco Berizzi for his perseverance in tracking this
> down.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued to -stable, thanks!
