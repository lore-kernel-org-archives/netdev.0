From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] stmmac: unify MAC and PHY configuration parameters
Date: Tue, 19 Jul 2011 11:57:38 -0700 (PDT)
Message-ID: <20110719.115738.131562530013095617.davem@davemloft.net>
References: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stuart.menefy@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab1GSS5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 14:57:46 -0400
In-Reply-To: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 19 Jul 2011 10:38:02 +0200

> Prior to this change, most PHY configuration parameters were passed
> into the STMMAC device as a separate PHY device. As well as being
> unusual, this made it difficult to make changes to the MAC/PHY
> relationship.
> 
> This patch moves all the PHY parameters into the MAC configuration
> structure, mainly as a separate structure. This allows us to completly
> ignore the MDIO bus attached to a stmmac if desired, and not create
> the PHY bus. It also allows the stmmac driver to use a different PHY
> from the one it is connected to, for example a fixed PHY or bit banging
> PHY.
> 
> Also derive the stmmac/PHY connection type (MII/RMII etc) from the
> mode can be passed into <platf>_configure_ethernet.
> STLinux kernel at git://git.stlinux.com/stm/linux-sh4-2.6.32.y.git
> provides several examples how to use this new infrastructure (that
> actually is easier to maintain and clearer).
> 
> Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

I find these changes confusing, because I can't see where these
platform data objects are created that end up being used by
the stmmac driver.

I'm concerned about this because if you're changing these data
structures, you'll need to update also the code that creates
these platform data objects.

Finally, this patch needs to update Documentation/networking/stmmac.txt

