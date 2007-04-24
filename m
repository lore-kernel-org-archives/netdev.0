From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 17:07:00 -0700 (PDT)
Message-ID: <20070423.170700.122831331.davem@davemloft.net>
References: <20070423153714.71b9d99e.akpm@linux-foundation.org>
	<20070423.154509.116354989.davem@davemloft.net>
	<20070424000458.GA21838@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, acme@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030835AbXDXAGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 20:06:53 -0400
In-Reply-To: <20070424000458.GA21838@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Apr 2007 10:04:58 +1000

> On Mon, Apr 23, 2007 at 03:45:09PM -0700, David Miller wrote:
> > 
> > Either that or some error in Herbert's recent checksum offload
> > handling changes, such as, in fact I am highly suspicious of
> > the second change listed below, you may want to try reverting
> > just that one:
> 
> Indeed.  My change depended on drivers correctly using csum_offset
> instead of the old csum field.  That was wrong anyway since sparse
> would now warn against that usage.  However, prior to my change it
> was harmless.
> 
> [NETDRV]: Perform missing csum_offset conversions
> 
> When csum_offset was introduced we did a conversion from csum to
> csum_offset where applicable.  A couple of drivers were missed in
> this process.
> 
> It was harmless to begin with since the two fields coincided.  Now
> that we've made them different with the addition of csum_start, the
> missed drivers must be converted or they can't send packets out at
> all that require checksum offload.
>      
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
