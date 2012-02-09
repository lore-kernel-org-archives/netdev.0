From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix driver features
Date: Thu, 09 Feb 2012 15:35:04 -0500 (EST)
Message-ID: <20120209.153504.92022308276431620.davem@davemloft.net>
References: <1328784993-31733-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757857Ab2BIUfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 15:35:11 -0500
In-Reply-To: <1328784993-31733-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  9 Feb 2012 11:56:33 +0100

> New GMAC chips can set the tx_coe and rx_csum
> flags by looking at the HW cap register and this
> happens during the open.
> This patch fixes the stmmac_fix_feature function that
> in some cases assumes that there is no HW csum
> because no flags are passed through the platform.
> As soon as the open method is called then the
> stmmac_fix_feature could want to turn-on the NETIF_F_RXCSUM
> or NETIF_F_ALL_CSUM.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This is not the purpose of the fix_features method, it's meant to
ensure that the settings are valid.

It's not meant to "catch up" with settings you store in the internal
datastructures of your driver.

You need to do this at probe time, where the initial ->hw_features
and ->features values are set.
