From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 13:07:02 +0100
Message-ID: <d5e99129-eef0-1d15-7277-e3c82435bf9f@synopsys.com>
References: <f43dda26d3c43fdf19d6872306741c16b635558c.1491989111.git.jpinto@synopsys.com>
 <20170412115643.GA32596@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:52638 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753892AbdDLMI5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 08:08:57 -0400
In-Reply-To: <20170412115643.GA32596@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Às 12:56 PM de 4/12/2017, Andrew Lunn escreveu:
> On Wed, Apr 12, 2017 at 10:26:20AM +0100, Joao Pinto wrote:
>> When the Drop Transmit Status bit is set, the Tx packet status
>> received from the MAC is dropped in the MTL. When this bit is reset,
>> the Tx packet status received from the MAC is forwarded to the
>> application. This feature will cause a performance improvement.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>> changes v1->v2:
>> - removed mask from dwmac4_enable_tx_drop()
>>
>>  Documentation/devicetree/bindings/net/stmmac.txt      |  1 +
>>  drivers/net/ethernet/stmicro/stmmac/common.h          |  2 ++
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h          |  1 +
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c     | 12 ++++++++++++
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  3 +++
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  2 ++
>>  include/linux/stmmac.h                                |  1 +
>>  7 files changed, 22 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
>> index f652b0c..dbcb2cc 100644
>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>> @@ -60,6 +60,7 @@ Optional properties:
>>  		 and MAC2MAC connection.
>>  - snps,tso: this enables the TSO feature otherwise it will be managed by
>>  		 MAC HW capability register. Only for GMAC4 and newer.
>> +- snps,drop-tx-status: this enables drop tx status
> 
> Hi Joao
> 
> Was the conclusion from testing that this cannot be turned on by
> default?

This feature is great for applications that need good performance, but has a
drawback since it has an impact in timestamp feature in Tx. There are some
operations in PTP where the timestamp is given to the host through the TX status
in the descriptor, so this will have an impact.

There's a way of solving this of course by making the driver checking the
timestamp in the MAC_Tx_Timestamp_Status_XXX registers, but I can only look into
that feature later in the future.

> 
> What sort of performance improvement did you get? Do you have some
> benchmark numbers?

My setup is FPGA based, so it will have lower performance values.
Iperf results with
  "Drop Transmit Status" set: ~650Mbps.
  "Drop Transmit Status" unset: ~450Mbps.

> 
> 	  Andrew
> 

Joao
