From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/3] drivers: net: ethernet: stmmac: fix failure in module
 test
Date: Wed, 23 May 2012 08:08:18 +0200
Message-ID: <4FBC7ED2.1080202@st.com>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com> <1337672336-7378-2-git-send-email-lliubbo@gmail.com> <4FBB8BBD.8010208@st.com> <CAA_GA1fNJCT=qfuHDkNrBdeZd8wiR30MPBdtUVuAv+ZY+zMH_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, francesco.virlinzi@st.com,
	rayagond@vayavyalabs.com, sr@denx.de, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:42978 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752082Ab2EWGJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:09:04 -0400
In-Reply-To: <CAA_GA1fNJCT=qfuHDkNrBdeZd8wiR30MPBdtUVuAv+ZY+zMH_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2012 7:09 AM, Bob Liu wrote:
> Hi Peppe,
> 
> On Tue, May 22, 2012 at 8:51 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> On 5/22/2012 9:38 AM, Bob Liu wrote:
>>> Module can't be compiled and installed in current Makefile.
>>
>> I've just seen that I can generate the stmmac.ko on ARM and also on x86
>> with my configuration.
>>
>> Can you post here you build failure?
>>
>> In the meantime I'll test the module on ARM soon.
> 
> Yes, stmmac.ko can be generated, but  stmmac_platform.c won't be built.
> which cause net device can't be probed.

Yes you are perfectly right!

I've just sent a patch following Ben's advice.

Also not clear if/how to build this as a system which supports both PCI
and platform versions of the driver. So the patch makes them mutually
exclusive.

Thanks a lot
peppe

> 
>>
>> peppe
>>
>>>
>>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>>> ---
>>>  drivers/net/ethernet/stmicro/stmmac/Makefile |   12 ++++++------
>>>  1 files changed, 6 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
>>> index bc965ac..4b50922 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
>>> @@ -1,10 +1,10 @@
>>>  obj-$(CONFIG_STMMAC_ETH) += stmmac.o
>>> -stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
>>> -stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
>>> -stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
>>> -stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
>>> -stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
>>> +stmmac-$(CONFIG_STMMAC_TIMER:m=y) += stmmac_timer.o
>>> +stmmac-$(CONFIG_STMMAC_RING:m=y) += ring_mode.o
>>> +stmmac-$(CONFIG_STMMAC_CHAINED:m=y) += chain_mode.o
>>> +stmmac-$(CONFIG_STMMAC_PLATFORM:m=y) += stmmac_platform.o
>>> +stmmac-$(CONFIG_STMMAC_PCI:m=y) += stmmac_pci.o
>>>  stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o   \
>>>             dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o     \
>>>             dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
>>> -           mmc_core.o $(stmmac-y)
>>> +           mmc_core.o
>>
> 
