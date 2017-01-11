From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH v2 0/2] remove dwc_eth_qos and rename stmicro/stmmac
Date: Wed, 11 Jan 2017 15:25:58 +0100
Message-ID: <d814eabb-ec19-9df4-1f44-4405ece6995f@st.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
 <298670a0-7074-a590-9498-7a9db68d499e@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33525 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1762085AbdAKO0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 09:26:10 -0500
In-Reply-To: <298670a0-7074-a590-9498-7a9db68d499e@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jao,

On 01/11/2017 12:54 PM, Joao Pinto wrote:
>
> Hi Alex,
>
> Às 11:39 AM de 1/11/2017, Alexandre Torgue escreveu:
>> Hi Jao,
>>
>> On 01/10/2017 03:52 PM, Joao Pinto wrote:
>>> This patch set removes the synopsys/dwc_eth_qos since it was merged recently
>>> to stmmac (dwmac-dwc-qos-eth glue driver).
>>>
>>> It also renames stmicro/stmmac to synopsys/ since it is a standard ethernet
>>> software package regarding synopsys ethernet controllers, supporting the
>>> majority of Synopsys Ethernet IPs.
>>
>> I understand the reason to rename stmmac driver. The only risk I see is that
>> usual user will be a little bit lost to find code. It seems there no risk of
>> backward compatibility with current/old DT (I assume you already checked this
>> point).
>
> I understand your concern, but for the Synopsys IPs users will be clearer what
> drivers to use and what current stmmac has to offer.

I agree.

>
> In terms of tests, I tested it and worked out of the box because the same
> Kconfig IDs were used assuring the retro-compatibility that David suggested a
> few weeks ago. For DT users no problems are expected as well.

Ok, sounds good.

I see that you rename also 
Documentation/devicetree/bindings/net/stmmac.txt. You have also to 
change some words inside as it talks about Stmicroelectronics.

Regards
Alex

>
> Thanks,
> Joao
>
>> Let's see what David think about that but if there no risk of backward
>> compatibility with DT, I agree with the series.
>>
>> Regards
>> Alex
>>
>>
>>
>>>
>>> In the future we should make an effort to migrate to this new synopsys/
>>> driver package all the Ethernet Synopsys IP drivers scattered in net/ethernet.
>>>
>>> Joao Pinto (2):
>>>   synopsys: remove dwc_eth_qos driver
>>>   stmmac: rename it to synopsys
>>>
>>>  .../bindings/net/{stmmac.txt => synopsys.txt}      |    0
>>>  MAINTAINERS                                        |   11 +-
>>>  arch/arm/configs/multi_v7_defconfig                |    3 +-
>>>  drivers/net/ethernet/Kconfig                       |    3 +-
>>>  drivers/net/ethernet/Makefile                      |    3 +-
>>>  drivers/net/ethernet/stmicro/Kconfig               |   21 -
>>>  drivers/net/ethernet/stmicro/Makefile              |    5 -
>>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |  162 --
>>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   25 -
>>>  drivers/net/ethernet/synopsys/Kconfig              |  165 +-
>>>  drivers/net/ethernet/synopsys/Makefile             |   28 +-
>>>  .../{stmicro/stmmac => synopsys}/altr_tse_pcs.c    |    0
>>>  .../{stmicro/stmmac => synopsys}/altr_tse_pcs.h    |    0
>>>  .../{stmicro/stmmac => synopsys}/chain_mode.c      |    0
>>>  .../ethernet/{stmicro/stmmac => synopsys}/common.h |    0
>>>  .../ethernet/{stmicro/stmmac => synopsys}/descs.h  |    0
>>>  .../{stmicro/stmmac => synopsys}/descs_com.h       |    0
>>>  drivers/net/ethernet/synopsys/dwc_eth_qos.c        | 2996 --------------------
>>>  .../stmmac => synopsys}/dwmac-dwc-qos-eth.c        |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-generic.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-ipq806x.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-lpc18xx.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-meson.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-meson8b.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-oxnas.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-rk.c        |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-socfpga.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-sti.c       |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-stm32.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac-sunxi.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac100.h        |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac1000.h       |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac1000_core.c  |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac1000_dma.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac100_core.c   |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac100_dma.c    |    0
>>>  .../ethernet/{stmicro/stmmac => synopsys}/dwmac4.h |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac4_core.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac4_descs.c    |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac4_descs.h    |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac4_dma.c      |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac4_dma.h      |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac4_lib.c      |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac_dma.h       |    0
>>>  .../{stmicro/stmmac => synopsys}/dwmac_lib.c       |    0
>>>  .../{stmicro/stmmac => synopsys}/enh_desc.c        |    0
>>>  .../ethernet/{stmicro/stmmac => synopsys}/mmc.h    |    0
>>>  .../{stmicro/stmmac => synopsys}/mmc_core.c        |    0
>>>  .../{stmicro/stmmac => synopsys}/norm_desc.c       |    0
>>>  .../{stmicro/stmmac => synopsys}/ring_mode.c       |    0
>>>  .../ethernet/{stmicro/stmmac => synopsys}/stmmac.h |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_ethtool.c  |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_hwtstamp.c |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_main.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_mdio.c     |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_pci.c      |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_pcs.h      |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_platform.c |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_platform.h |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_ptp.c      |    0
>>>  .../{stmicro/stmmac => synopsys}/stmmac_ptp.h      |    0
>>>  61 files changed, 180 insertions(+), 3242 deletions(-)
>>>  rename Documentation/devicetree/bindings/net/{stmmac.txt => synopsys.txt} (100%)
>>>  delete mode 100644 drivers/net/ethernet/stmicro/Kconfig
>>>  delete mode 100644 drivers/net/ethernet/stmicro/Makefile
>>>  delete mode 100644 drivers/net/ethernet/stmicro/stmmac/Kconfig
>>>  delete mode 100644 drivers/net/ethernet/stmicro/stmmac/Makefile
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/altr_tse_pcs.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/altr_tse_pcs.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/chain_mode.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/common.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/descs.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/descs_com.h (100%)
>>>  delete mode 100644 drivers/net/ethernet/synopsys/dwc_eth_qos.c
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-dwc-qos-eth.c
>>> (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-generic.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-ipq806x.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-lpc18xx.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-meson.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-meson8b.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-oxnas.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-rk.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-socfpga.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-sti.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-stm32.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-sunxi.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac100.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac1000.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac1000_core.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac1000_dma.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac100_core.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac100_dma.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_core.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_descs.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_descs.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_dma.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_dma.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_lib.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac_dma.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac_lib.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/enh_desc.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/mmc.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/mmc_core.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/norm_desc.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/ring_mode.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_ethtool.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_hwtstamp.c
>>> (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_main.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_mdio.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_pci.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_pcs.h (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_platform.c
>>> (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_platform.h
>>> (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_ptp.c (100%)
>>>  rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_ptp.h (100%)
>>>
>
