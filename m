From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] net: phy: at803x: disable by default the
 hibernation feature
Date: Mon, 31 Oct 2016 11:03:34 -0400 (EDT)
Message-ID: <20161031.110334.1176462972951777560.davem@davemloft.net>
References: <1477384282-17878-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ujhelyi.m@gmail.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943776AbcJaPDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 11:03:36 -0400
In-Reply-To: <1477384282-17878-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 25 Oct 2016 10:31:22 +0200

> These PHY chips, by default, enable the hibernation feature
> so, if the cable is unplugged the device enters in hibernation
> mode after some time. This can generate problems on some cases.
> It has been noticed, on some platforms that, if the phy enters
> in hibernation, the missing of the rx clock signal can force
> a mac to fail when setup some parts that need to be properly
> clocked.
> For example, while booting a Kernel the SYNP MAC (stmmac) fails
> to initialize own DMA engine if the phy entered in hibernation
> before.
> 
> So, the patch just disables this feature by default when init
> the PHY driver.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Matus Ujhelyi <ujhelyi.m@gmail.com>

Like Andrew, I think this is attacking the problem from the wrong
side.

The stmmac driver, if it needs the proper PHY RX clocks to initialize
properly, should do the work to make sure it is there.

If this means forcing the PHY out of hibernation mode, so that it
can initialize properly, this is what the stammc can do.

After initialization, it can allow the chip to fall back into
hibernation mode again if the cable is still unplugged.

Disabling a whole feature of the PHY instead doesn't make a lot of
sense when it certainly seems like stmmac can do what it needs to do
in the presence of this feature being enabled.
