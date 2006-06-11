From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 16:28:56 -0400
Message-ID: <20060611202856.GA9868@kvack.org>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net> <448C4C7A.7020301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org, mingo@elte.hu,
	arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:33501 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1750963AbWFKU3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 16:29:08 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <448C4C7A.7020301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The above code snippet removes the nested unlock-irq, but now the code 
> is unbalanced, so IMO this patch _adds_ confusion.
> 
> I think the conservative patch for 2.6.17 is the one I have attached. 
> Unless there are objections, that is what I will forward...

This looks reasonable and sufficiently conservative.  Reworking locking is 
something that I'm a bit more hesitant about, although folding misc_lock 
in with the other locks perhaps makes sense.  I would like to keep the 
split between tx and tx completion, though.  Also, any rework is going to 
need real testing, which is not something that a simple release cycle is 
likely to get enough coverage on.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
