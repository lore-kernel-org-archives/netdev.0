From: David Miller <davem@davemloft.net>
Subject: Re: [Stlinux-devel] [PATCH linux-stm 1/4] net:stmmac: Add check if
 mdiobus is registered in stmmac_mdio_unregister
Date: Fri, 31 Aug 2012 16:12:43 -0400 (EDT)
Message-ID: <20120831.161243.2158415044562484305.davem@davemloft.net>
References: <1346341798-19704-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab2HaUMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:12:45 -0400
In-Reply-To: <1346341798-19704-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Thu, 30 Aug 2012 16:49:58 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch adds a basic check in stmmac_mdio_unregister to see if mdio
> bus registeration for this driver was actually sucessfull or not.
> 
> Use case here is, if BSP considers using mdio-gpio bus along with stmmac
> driver by passing mdio_bus_data as NULL in platform data.
> Call to stmmac_mdio_register with mdio_bus_data as NULL returns 0, which
> is a considered sucessfull call form stmmac. Then again when we unload
> the driver we just call stmmac_mdio_unregister, this is were the actual
> problem is stmmac-mdio code dont really know at this instance of calling
> that stmmac_mdio_register was actually successful.
> 
> So Adding a check in stmmac_mdio_unregister is always safe.
> 
> Without this patch stmmac driver calls stmmac_mdio_register from
> stmmac_release which Segfaults as mii bus was never registered at the
> first point.
> 
> Originally the this bug was found when unloading an stmmac driver
> instance which uses mdio-gpio for smi access.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied.
