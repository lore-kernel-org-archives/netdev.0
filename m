From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Inline local_bh_disable when TRACE_IRQFLAGS
Date: Wed, 19 Dec 2007 12:31:52 +0100
Message-ID: <20071219113152.GD20736@elte.hu>
References: <20071219034033.GA5770@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55721 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbXLSLcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 06:32:13 -0500
Content-Disposition: inline
In-Reply-To: <20071219034033.GA5770@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Ingo:
> 
> I noticed that local_bh_disable is now always out-of-line.  The change 
> was made when TRACE_IRQFLAGS was added.  However, with TRACE_IRQFLAGS 
> off, local_bh_disable does exactly the same work as before.  In 
> particular, it does pretty much the same as what preempt_disable does 
> and the latter is always inline.
> 
> So I'm wondering if it would be reasonable to make it out-of-line when 
> TRACE_IRQFLAGS is off.  This may make a difference because the 
> networking stack is a frequent user of local_bh_disable and 
> local_bh_enable.

do you mean to make it inline again?

(btw., generally i think local_bh_disable() is a poor API because it is 
opaque about the data structure dependency that it governs. Explicit 
exclusion rules generally work better.)

	Ingo
