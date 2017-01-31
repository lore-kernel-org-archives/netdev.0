From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 00/17] net: stmmac: misc fix
Date: Tue, 31 Jan 2017 10:23:33 +0000
Message-ID: <684e493d-b1ea-23d7-fd6f-1f3aa89e7f4c@synopsys.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <c04f9218-0661-7cb6-c18f-46fd420c6e28@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:50725 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751367AbdAaKaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:30:03 -0500
In-Reply-To: <c04f9218-0661-7cb6-c18f-46fd420c6e28@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Peppe,

Às 10:00 AM de 1/31/2017, Giuseppe CAVALLARO escreveu:
> Hello Corentin
> 
> On 1/31/2017 10:11 AM, Corentin Labbe wrote:
>> Hello
>>
>> I am currently working on dwmac-sun8i glue driver for Allwinner H3/A83T/A64.
>> This serie is the result of all minor problem found in the stmmac driver.
> 
> thank for this effort, many changes are to tidy up some part of the code
> so  I wonder if these should stay on top of net-next.
> There is on-going a thread to change something in the stmmac (where I
> missed more details and I tried to refresh all asap); so added on copy
> Joao.

I submitted 2 suggestions that would rename folder stmicro to dwc and dwmac4*
files to eqos. The second one is important, since there is no dwmc4/gmac4 core,
in fact it is called eqos that will have 5.00 version very soon. Both
suggestions were rejected and so I turned to developing features.
I am available to discuss with you any improvement on these aspects if you think
it makes sense.

Currently I am developing the support for multi-queues / multi-channels which
will enable in the future stmmac to be used in QAv and TSN applications.

Thanks,
Joao

> 
> I will give you my feedback on some patches too.
> 
> peppe
> 
>> Regards
>>
>> Corentin Labbe (17):
>>   net: stmmac: fix the typo on MAC_RNABLE_RX
>>   net: stmmac: Remove the bus_setup function pointer
>>   net: stmmac: fix some typos in comments
>>   net: stmmac: remove freesoftware address
>>   net: stmmac: remplace asm/io.h by linux/io.h
>>   net: stmmac: fix some code style problem
>>   net: stmmac: replace stmmac_mdio_busy_wait by readl_poll_timeout
>>   net: stmmac: Use readl_poll_timeout
>>   net: stmmac: replace ENOSYS by EINVAL
>>   net: stmmac: Correct the error message about invalid speed
>>   net: stmmac: Rewrite two test against NULL value
>>   net: stmmac: rename rx_crc to rx_crc_errors
>>   net: stmmac: Implement NAPI for TX
>>   net: stmmac: print phy information
>>   net: stmmac: remove dead code in stmmac_tx_clean
>>   net: stmmac: remove unused variable in sysfs_display_ring
>>   net: stmmac: replace unsigned by u32
>>
>>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/common.h       |  8 +--
>>  drivers/net/ethernet/stmicro/stmmac/descs.h        |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/descs_com.h    |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/dwmac100.h     |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  4 --
>>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  4 --
>>  .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |  4 --
>>  .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c |  2 +-
>>  drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    | 28 ++++------
>>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  6 +--
>>  drivers/net/ethernet/stmicro/stmmac/mmc.h          |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/mmc_core.c     |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |  6 +--
>>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  4 --
>>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  6 +--
>>  .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 63 ++++++++++------------
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 52 +++++++-----------
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  4 --
>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  6 +--
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  4 --
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |  4 --
>>  include/linux/stmmac.h                             |  1 -
>>  28 files changed, 65 insertions(+), 185 deletions(-)
>>
> 
