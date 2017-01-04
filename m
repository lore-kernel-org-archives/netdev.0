From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 0/3] adding new glue driver dwmac-dwc-qos-eth
Date: Wed, 4 Jan 2017 13:46:27 +0000
Message-ID: <618fed99-1c88-9cbe-62e7-9bac1f564061@synopsys.com>
References: <cover.1483530191.git.jpinto@synopsys.com>
 <34837f5b-afb8-92df-f12e-2fa5514558be@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <larper@axis.com>, <swarren@nvidia.com>, <treding@nvidia.com>,
        <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:53282 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967153AbdADNqg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 08:46:36 -0500
In-Reply-To: <34837f5b-afb8-92df-f12e-2fa5514558be@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 1:43 PM de 1/4/2017, Niklas Cassel escreveu:
> Let's see if patchwork is smart enough to add the tag to the whole series.
> 
> Tested-by: Niklas Cassel <niklas.cassel@axis.com>

I got this compile error due to dwmac-socfpga twist:

config: i386-allmodconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386

All errors (new ones prefixed by >>):

   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c: In function
'socfpga_dwmac_probe':
>> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:344:28: error: 'struct
stmmac_priv' has no member named 'stmmac_rst'
     dwmac->stmmac_rst = stpriv->stmmac_rst;

I am going to fix socfpga and submit v3 :). Hopefully everything' got ok!

Thanks

> 
> On 01/04/2017 12:48 PM, Joao Pinto wrote:
>> This patch set contains the porting of the synopsys/dwc_eth_qos.c driver
>> to the stmmac structure. This operation resulted in the creation of a new
>> platform glue driver called dwmac-dwc-qos-eth which was based in the
>> dwc_eth_qos as is.
>>
>> dwmac-dwc-qos-eth inherited dwc_eth_qos DT bindings, to assure that current
>> and old users can continue to use it as before. We can see this driver as
>> being deprecated, since all new development will be done in stmmac.
>>
>> Please check each patch for implementation details.
>>
>> Joao Pinto (3):
>>   stmmac: adding DT parameter for LPI tx clock gating
>>   stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform
>>     structure
>>   stmmac: adding new glue driver dwmac-dwc-qos-eth
>>
>>  .../bindings/net/snps,dwc-qos-ethernet.txt         |   3 +
>>  Documentation/devicetree/bindings/net/stmmac.txt   |   2 +
>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 +
>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>>  drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +-
>>  .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 200 +++++++++++++++++++++
>>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   5 +-
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |   1 +
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |   6 +-
>>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   5 -
>>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   4 +-
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  85 ++-------
>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  65 ++++++-
>>  include/linux/stmmac.h                             |   6 +
>>  14 files changed, 314 insertions(+), 81 deletions(-)
>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>>
> 
