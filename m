From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Inline local_bh_disable when TRACE_IRQFLAGS
Date: Wed, 19 Dec 2007 11:40:33 +0800
Message-ID: <20071219034033.GA5770@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2868 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751535AbXLSDkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 22:40:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ingo:

I noticed that local_bh_disable is now always out-of-line.  The
change was made when TRACE_IRQFLAGS was added.  However, with
TRACE_IRQFLAGS off, local_bh_disable does exactly the same work
as before.  In particular, it does pretty much the same as what
preempt_disable does and the latter is always inline.

So I'm wondering if it would be reasonable to make it out-of-line
when TRACE_IRQFLAGS is off.  This may make a difference because
the networking stack is a frequent user of local_bh_disable and
local_bh_enable.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
