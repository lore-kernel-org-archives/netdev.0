From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: do not sleep in atomic context for mdio_reset
Date: Thu, 02 Jun 2016 12:12:45 -0700 (PDT)
Message-ID: <20160602.121245.1302730459604436490.davem@davemloft.net>
References: <1464796428-25623-1-git-send-email-vpalatin@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexandre.torgue@st.com, peppe.cavallaro@st.com
To: vpalatin@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161368AbcFBTMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 15:12:47 -0400
In-Reply-To: <1464796428-25623-1-git-send-email-vpalatin@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Palatin <vpalatin@chromium.org>
Date: Wed,  1 Jun 2016 08:53:48 -0700

> stmmac_mdio_reset() has been updated to use msleep rather udelay
> (as some PHY requires a one second delay there).
> It called from stmmac_resume() within the spin_lock_irqsave block
> atomic context triggering 'scheduling while atomic'.
> 
> The stmmac_priv lock usage is not fully documented, but it seems
> to protect the access to the MAC registers / DMA structures rather
> than the MDIO bus or the PHY (which have separate locking),
> so we can push the spin_lock after the stmmac_mdio_reset call.
> 
> Signed-off-by: Vincent Palatin <vpalatin@chromium.org>

Applied, thanks.
