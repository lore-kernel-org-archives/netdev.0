From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 0/4] EEE for PAL and stmmac (V6)
Date: Wed, 27 Jun 2012 08:07:33 +0200
Message-ID: <4FEAA325.4060909@st.com>
References: <1340258599-3083-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:51384 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753290Ab2F0GII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 02:08:08 -0400
In-Reply-To: <1340258599-3083-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/2012 8:03 AM, Giuseppe CAVALLARO wrote:
> These patches add the EEE support in the stmmac device driver
> restoring an old work I had done some months ago and not
> completed in time.
> 
> I've tested all on ST STB with the IC+ 101G PHY device that has
> this feature.
> 
> The initial EEE support for the stmmac has been written by Rayagond
> but I have reworked all his code adding new parts and especially
> performing tests on a real hardware. Thx Rayagond!
> 
> In these patches, we can see that the stmmac supports the EEE
> only if the DMA HW capability register says that this
> feature is actually available. In that case, the driver can enter
> in the Tx LPI mode by using a timer as recommended by Synopsys.
> Note that EEE is supported in new chip generations; in particular
> I used the 3.61a.
> 
> At any rate, further information about how the driver treats the EEE
> can be found in the stmmac.txt file (there is a patch for that).
> 
> Another patch is for Physical Abstraction Layer now able to
> manage the MMD registers (clause 45); it also provides the ethtool
> support to manage supported/advertisement/lp adv features.
> 
> v3: fixed the "stmmac: do not use strict_strtoul but kstrtoint"
>     to use the kstrtoint.
> v4: fixed the function to enable the EEE and add a check that verifies
>     if the link auto-negotiated matches with the bits in the adv and lp
>     registers.
> v5: reviewed the way to get the negotiated settings
> v6: fixed a broken return value in the phy_eee_init function
> Giuseppe Cavallaro (4):
>   stmmac: do not use strict_strtoul but kstrtoint
>   stmmac: update the driver Documentation and add EEE
>   stmmac: add the Energy Efficient Ethernet support
>   phy: add the EEE support and the way to access to the MMD registers.

Hello Ben

sorry if I stress you but I wonder if the v8 version of the latest patch
([net-next.git 4/4 (v8)] phy: add the EEE support and the way to access
to the MMD registers.) is ok for you or if I have to fix something else.

Many thanks for your effort.

Let me know.

Best Regards
Peppe

>  Documentation/networking/stmmac.txt                |   36 ++-
>  drivers/net/ethernet/stmicro/stmmac/common.h       |   31 ++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   20 ++
>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  101 +++++++-
>  .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    4 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    8 +
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   57 ++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  193 ++++++++++++--
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +
>  drivers/net/phy/phy.c                              |  281 ++++++++++++++++++++
>  include/linux/mdio.h                               |   21 ++-
>  include/linux/mii.h                                |    9 +
>  include/linux/phy.h                                |    5 +
>  14 files changed, 724 insertions(+), 45 deletions(-)
> 
