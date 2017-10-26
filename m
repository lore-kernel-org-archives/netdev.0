From: Bhadram Varka <vbhadram@nvidia.com>
Subject: RE: [PATCH net] net: stmmac: First Queue must always be in DCB mode
Date: Thu, 26 Oct 2017 14:44:08 +0000
Message-ID: <e8c0fbdc83084cafa4191257a26a81ef@bgmail102.nvidia.com>
References: <d0f29981af9cfc700709af274acd7dba4b2014a7.1509008601.git.joabreu@synopsys.com>
 <c58a62cc2971476b95e34096eb32f852@bgmail102.nvidia.com>
 <73ccf81c-6865-9e02-83e1-5ba1e4d5e918@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Jose Abreu <Jose.Abreu@synopsys.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:12419 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932246AbdJZOqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:46:10 -0400
In-Reply-To: <73ccf81c-6865-9e02-83e1-5ba1e4d5e918@synopsys.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jose,

> -----Original Message-----
> From: Jose Abreu [mailto:Jose.Abreu@synopsys.com]
> Sent: Thursday, October 26, 2017 5:19 PM
> To: Bhadram Varka <vbhadram@nvidia.com>; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org
> Cc: Joao Pinto <Joao.Pinto@synopsys.com>; David S. Miller
> <davem@davemloft.net>; Giuseppe Cavallaro <peppe.cavallaro@st.com>;
> Alexandre Torgue <alexandre.torgue@st.com>
> Subject: Re: [PATCH net] net: stmmac: First Queue must always be in DCB
> mode
> 
> Hi Bhadram,
> 
> On 26-10-2017 11:51, Bhadram Varka wrote:
> > Hi Jose,
> >
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> owner@vger.kernel.org] On Behalf Of Jose Abreu
> >> Sent: Thursday, October 26, 2017 2:37 PM
> >> To: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> >> Cc: Jose Abreu <Jose.Abreu@synopsys.com>; Joao Pinto
> >> <Joao.Pinto@synopsys.com>; David S. Miller <davem@davemloft.net>;
> >> Giuseppe Cavallaro <peppe.cavallaro@st.com>; Alexandre Torgue
> >> <alexandre.torgue@st.com>
> >> Subject: [PATCH net] net: stmmac: First Queue must always be in DCB
> >> mode
> >>
> >> According to DWMAC databook the first queue operating mode must
> >> always be in DCB.
> >>
> >> As MTL_QUEUE_DCB = 1, we need to always set the first queue operating
> >> mode to DCB otherwise driver will think that queue is in AVB mode
> >> (because MTL_QUEUE_AVB = 0).
> >>
> >> Signed-off-by: Jose Abreu <joabreu@synopsys.com>
> >> Cc: Joao Pinto <jpinto@synopsys.com>
> >> Cc: David S. Miller <davem@davemloft.net>
> >> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> >> Cc: Alexandre Torgue <alexandre.torgue@st.com>
> >> ---
> >>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 7 +++++++
> >>  1 file changed, 7 insertions(+)
> >>
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> >> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> >> index 21f59fe..603225b 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> >> @@ -150,6 +150,13 @@ static void stmmac_mtl_setup(struct
> >> platform_device *pdev,
> >>  	plat->rx_queues_to_use = 1;
> >>  	plat->tx_queues_to_use = 1;
> >>
> >> +	/* First Queue must always be in DCB mode. As MTL_QUEUE_DCB =
> >> 1 we need
> >> +	 * to always set this, otherwise Queue will be classified as AVB
> >> +	 * (because MTL_QUEUE_AVB = 0).
> >> +	 */
> > Its better if we can check whether IP HW features (register - 0x120)
> supports the DCB or not. If yes, then set the DCB mode.
> > There is possibility that DCB feature not enable for few of the Synopsys
> IP's.
> 
> A queue can either be in Generic/DCB or AVB mode. The sequence to enable
> a DCB or a Generic queue is the same so there is no need to check for DCB
> capability in HW.

Point is that we don't have DCB enabled for the IP. 

>From your point it will work in Generic (legacy) mode if we set DCB filed. If this is the understanding then we are fine.

Thanks,
Bhadram.
