From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: prevent false carrier sense detection
Date: Fri, 29 Aug 2014 19:55:39 -0700 (PDT)
Message-ID: <20140829.195539.1489311917586365339.davem@davemloft.net>
References: <1409120404-20414-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaH3Czm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 22:55:42 -0400
In-Reply-To: <1409120404-20414-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 27 Aug 2014 08:20:04 +0200

> This patch is to w/a a problem that happens on some boxes when run at 10Mbps
> Half duplex mode.
> 
> During the transmission the CSR signal is asserted for some time and the frames
> aborted because of carrier sense error.
> This is reported by MMC HW counter: txcarrier signal.
> This actually is a false carrier so the frames are good and there is no reason
> to ask for dropping them.
> 
> This patch so disables the Carrier Sense During Transmission
> and this means that the MAC transmitter ignore the CRS signal
> during frame transmission in Half-Duplex mode.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Acked-by: Vince Bridgers <vbridgers2013@gmail.com>
> Acked-by: Ley Foon Tan <lftan@altera.com>
> Acked-by: Chen-Yu Tsai <wens@csie.org>

Applied.

Although it would have made more sense to me if you only set the DCRS bit
in the case where the troubles occur, half-duplex 10Mbps, so that in other
modes real carrier loss during transmit would actually be detected.
