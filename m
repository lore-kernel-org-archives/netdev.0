From: Matthias Brugger <matthias.bgg@gmail.com>
Subject: Re: [PATCH v1 0/6] drivers: net: xgene: Fix 1G hot-plug and module
 support
Date: Fri, 27 May 2016 19:07:04 +0200
Message-ID: <57487EB8.6040309@gmail.com>
References: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33786 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682AbcE0RHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 13:07:10 -0400
In-Reply-To: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/05/16 09:22, Iyappan Subramanian wrote:
> This patchset addresses the following issues,
>
> 1. hot-plug issue on the SGMII 1G interface
> 	- by adding a driver for MDIO management
> 2. fixes the kernel crash when the driver loaded as an kernel module
> 	- by fixing hardware cleanups and rearrange kernel API calls
>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> ---

Without this patches we observed problems on some hardware when the 
driver was loaded as modules, as well as the kernel crash when 
unloading/loading the module.

I tested this with an older FW and both issues are fixed, so you can add

Tested-by: Matthias Brugger <mbrugger@suse.com>

But I think the way the series is split in different patches is not 
correct. Patch 1 on its own won't compile and get fixed in patch 2.
Although I think backward compatibility to older firmware should be part 
of the changes which provide support for the new firmware and should not 
be a patch apart. Said this, I'm not sure if just squashing patch 1 and 
patch 2 is the right to do, as to me it seems as if some other fixes 
slipped into the series.

 From my point of view, patch 4 and 5 should be squashed, as xge0clk and 
sge1clk nodes are useless when the mdio nodes are present.

Regards,
Matthias

>
> Iyappan Subramanian (6):
>    drivers: net: xgene: MAC and PHY configuration changes
>    drivers: net: xgene: Backward compatibility with older firmware
>    drivers: net: phy: Add MDIO driver
>    dtb: xgene: Add MDIO node
>    dtb: xgene: Remove clock nodes
>    drivers: net: xgene: Fix module load/unload crash
>
>   arch/arm64/boot/dts/apm/apm-merlin.dts            |  10 +
>   arch/arm64/boot/dts/apm/apm-mustang.dts           |  12 +
>   arch/arm64/boot/dts/apm/apm-shadowcat.dtsi        |  23 +-
>   arch/arm64/boot/dts/apm/apm-storm.dtsi            |  38 +-
>   drivers/net/ethernet/apm/xgene/Kconfig            |   1 +
>   drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 241 ++++++----
>   drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  18 +-
>   drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 325 ++++++++-----
>   drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  36 +-
>   drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 191 +++++++-
>   drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |   8 +
>   drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  66 ++-
>   drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   4 +
>   drivers/net/phy/Kconfig                           |   7 +
>   drivers/net/phy/Makefile                          |   1 +
>   drivers/net/phy/mdio-xgene.c                      | 531 ++++++++++++++++++++++
>   drivers/net/phy/mdio-xgene.h                      | 140 ++++++
>   17 files changed, 1373 insertions(+), 279 deletions(-)
>   create mode 100644 drivers/net/phy/mdio-xgene.c
>   create mode 100644 drivers/net/phy/mdio-xgene.h
>
