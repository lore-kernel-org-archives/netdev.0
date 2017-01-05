From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmmac: Enable Clause 45 PHYs in GMAC4 (eQOS)
Date: Thu, 5 Jan 2017 10:15:40 +0000
Message-ID: <10566e92-d7d3-c947-2e2d-c9c9f5b08d89@synopsys.com>
References: <14201d58c172f7a65b03510d36d55170f4d16cd5.1483540094.git.jpinto@synopsys.com>
 <F54AEECA5E2B9541821D670476DAE19C5A91819D@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:45604 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938356AbdAEKPp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 05:15:45 -0500
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C5A91819D@PGSMSX102.gar.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 1:37 AM de 1/5/2017, Kweh, Hock Leong escreveu:
>> -----Original Message-----
>> From: Joao Pinto [mailto:Joao.Pinto@synopsys.com]
>> Sent: Wednesday, January 04, 2017 10:36 PM
>> To: davem@davemloft.net
>> Cc: Kweh, Hock Leong <hock.leong.kweh@intel.com>; netdev@vger.kernel.org;
>> Joao Pinto <Joao.Pinto@synopsys.com>
>> Subject: [PATCH] stmmac: Enable Clause 45 PHYs in GMAC4 (eQOS)
>>
>> The eQOS IP Core (best known in stmmac as gmac4) has a register that must be
>> set if using a Clause 45 PHY. If this register is not set, the PHY won't work.
>> This patch will have no impact in setups using Clause 22 PHYs.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> 
> Hi Joao,
> 
> This is not working on our environment. We are using the 4-ETH-4-MGB-101 plugin card.
> 
> Regards,
> Wilson

Hi Wilson and David,
I am using a different PHY and I only get it detecting the link with that bit
set. Thanks for your feedback, going to dig a bit more!

Joao


> 
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> index b0344c2..676ae3c 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> @@ -41,6 +41,7 @@
>>  #define MII_GMAC4_GOC_SHIFT		2
>>  #define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
>>  #define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
>> +#define MII_CLAUSE45_PHY		(1 << 1)
>>
>>  static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int
>> mii_addr)  { @@ -125,7 +126,7 @@ static int stmmac_mdio_write(struct
>> mii_bus *bus, int phyaddr, int phyreg,
>>  	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
>>  		& priv->hw->mii.clk_csr_mask;
>>  	if (priv->plat->has_gmac4)
>> -		value |= MII_GMAC4_WRITE;
>> +		value |= MII_GMAC4_WRITE | MII_CLAUSE45_PHY;
>>  	else
>>  		value |= MII_WRITE;
>>
>> --
>> 2.9.3
> 
