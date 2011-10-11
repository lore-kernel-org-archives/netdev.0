From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/5] stmmac: add CHAINED descriptor mode support
Date: Tue, 11 Oct 2011 15:42:03 -0400 (EDT)
Message-ID: <20111011.154203.569015025155780686.davem@davemloft.net>
References: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
	<1318318246-1326-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933Ab1JKTmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 15:42:11 -0400
In-Reply-To: <1318318246-1326-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 11 Oct 2011 09:30:42 +0200

> From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> 
> This patch enhances the STMMAC driver to support CHAINED mode of
> descriptor (useful also on validation side).
> 
> STMMAC supports DMA descriptor to operate both in dual buffer(RING)
> and linked-list(CHAINED) mode. In RING mode (default) each descriptor
> points to two data buffer pointers whereas in CHAINED mode they point
> to only one data buffer pointer.
> 
> In CHAINED mode each descriptor will have pointer to next descriptor in
> the list, hence creating the explicit chaining in the descriptor itself,
> whereas such explicit chaining is not possible in RING mode.
> 
> Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

These ifdefs added all over the place in the foo.c files are terrible.

Abstract out the differences between RING and CHAINED mode into helper
inline routines which live in some foo.h header file, that way you won't
need any ifdefs in the driver foo.c files.
