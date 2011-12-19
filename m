From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: reduce queue lengths if MTU is very large
Date: Mon, 19 Dec 2011 16:33:37 -0500 (EST)
Message-ID: <20111219.163337.1185514300243434827.davem@davemloft.net>
References: <1324273530-18499-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rubini@gnudd.com, giancarlo.asnaghi@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1LSVf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:35:29 -0500
In-Reply-To: <1324273530-18499-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 19 Dec 2011 06:45:30 +0100

> From: Alessandro Rubini <rubini@gnudd.com>
> 
> In my use case (STA2X11 IO-Hub), the alloc_coherent, map_single and
> friends map to a reserved area set up in swiotlb.  With the default
> MTU each packet takes 2kB, but with jumbo frames it increases to 16kB
> and consumes up my area (it takes 8MB instead of 1MB).
> 
> Instead of increasing the reserved (== wasted) preallocated area in
> swiotlb, this patch rescales the user-selected queue lengths if the MTU
> is modified at runtime to be larger than the default. User choices
> are still obeyed (compiled default, module parameter, command line)
> 
> Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
> Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This change doesn't make sense.

If the user is only sending/receiving small frames, then this patch
will hurt them.

I'm not applying this, it just points out that the amount of reserved
space in your SWIOMMU setup might be insufficient for this situation
rather than something that should be tweaked in this driver.
