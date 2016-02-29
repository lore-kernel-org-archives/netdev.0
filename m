From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v3 00/17] stmmac: enhance driver performances and update
 the version
Date: Mon, 29 Feb 2016 17:50:11 +0100
Message-ID: <56D476C3.6030103@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre TORGUE <alexandre.torgue@st.com>,
	<fabrice.gasnier@st.com>, Joachim Eastwood <manabian@gmail.com>
To: <netdev@vger.kernel.org>, <maxime.coquelin@st.com>,
	<rabinv@axis.com>, <larper@axis.com>,
	Rayagond K <rayagond@vayavyalabs.com>, <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:7278 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750718AbcB2QuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 11:50:18 -0500
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gents

on top of these patches, there is a new train to enhance the stmmac to
support the DWMAC_4.x chips. They will be proposed very soon and on
top of this update (as soon as reviewed and merged).

In our context, it has been very useful working with the same driver
that runs fine on several (x86, arm, sh4) boxes with different SYNP
MAC/GMAC IPs (starting from MAC10/100 Database Release 1.5 to databook
3.70a and .... 4.00a and 4.10a). We got the benefit to have all the
features already supported by stmmac plus the good performances
available with TSO on gmac4.

I can image no big issues to enhance the stmmac on supporting the
new 4.00a and 4.10a although there is some other work made by
Rabin and Larper.

I guess, stmmac users will continue to be happy to continue to have the
same d.d. working on their platforms with new gmac.
But! it also makes sense to avoid to have two drivers that aim
to do the same job. Or to get more synergy on the same code as
done in the past with Rayagond for PTP and EEE.

If you have some concern or advice, please do not hesitate to ask.
We will try to send the patches soon to show the code in case of
people are interested in.

Kind Regards
Peppe

On 2/29/2016 2:27 PM, Alexandre TORGUE wrote:
> According to Giuseppe, I send the v3 series.
>
> This is a subset of patches to rework the driver in order to improve its
> performances and make it more robust under stress conditions.
>
> All patches have been ported on STi mainstream kernel branch and
> tested on ARM STiH4xx platforms and newer ones.
>
> This series also updates the driver version and prepares it
> to include further development to support new chips.
>
> In detail, these patches are:
>
> o to rework and improve the internal DMA bus settings
>
>    Fine tuning is mandatory on some platforms for both
>    performance and stability issues.
>
> o to rework and optimize the descriptor management.
>
>    This will help a lot on performance side and preparing
>    the inclusion on the GMAC4.x.
>
> o to add a set of optimizations for both xmit and rx functions.
>
>    These will help a lot on performance side and making the driver
>    more robust in case of low memory conditions and under some
>    stress test, performed for example on IP-STB.
>
> Below some throughput figures obtained on some boxes before and after
> the patches.
>
>                         nuttcp (mbps)       iperf (Mbps)
> ------------------------------------------------------------------
>                        tcp     udp          tcp      udp
>                     tx   rx   tx  rx      tx   rx   tx  rx
>                      ------------------------------------------
>     old             680   800 480  506    760  800   600  700
>     new             830   880 540  630    840  880   700   800
>
> ==============================================================================
>
> V2: - rx_copybreak is now managed by using ethtool.
> V3: - improve comments on PCIe detailing that there are no regressions
>      - rework some APIs to properly define some params as bool as expected
>      - rework the formula to get the element inside the ring. Comparing V2,
> 	patches 4 and 13 have been merged because the same formula have been
> 	used. After this rework, no evident benefit has been noticed in terms
> 	of performances so the table above is still valid. Disassembling the
> 	code for SH4 and ARM, with the new formula just an instr is saved
> 	(depending on compiler flags) and this gives us not so relevanti gain,
> 	for example, on SH4 where some instr are executed in the same pipeline
> 	stage.
> 	Ring sizes are now fixed and maybe they can be reworked to be tuned
> 	w/o using stmmaceth= cmdline option. Indeed, nobody change these sizes
> 	and indeed the numbers selected by default respect the budget and
> 	avoid to pass invalid setup. These are the best driver default sizes
> 	for ring and chain.
>
> ==============================================================================
> Fabrice Gasnier (3):
>    stmmac: merge get_rx_owner into rx_status routine.
>    stmmac: optimize tx clean function
>    stmmac: fix phy init when attached to a phy
>
> Giuseppe Cavallaro (14):
>    stmmac: share reset function between dwmac100 and dwmac1000
>    stmmac: rework DMA bus setting and introduce new platform AXI
>      structure
>    stmmac: change descriptor layout
>    stmmac: review RX/TX ring management
>    stmmac: add length field to dma data
>    stmmac: add last_segment field to dma data
>    stmmac: add is_jumbo field to dma data
>    stmmac: optimize tx desc management
>    stmmac: set dirty index out of the loop
>    stmmac: first frame prep at the end of xmit routine
>    stmmac: do not poll phy handler when attach a switch
>    stmmac: do not perform zero-copy for rx frames
>    stmmac: tune rx copy via threshold.
>    stmmac: update version to Oct_2015
>
>   Documentation/devicetree/bindings/net/stmmac.txt   |  54 ++-
>   drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |  37 +-
>   drivers/net/ethernet/stmicro/stmmac/common.h       |  39 +-
>   drivers/net/ethernet/stmicro/stmmac/descs.h        | 330 +++++++-------
>   drivers/net/ethernet/stmicro/stmmac/descs_com.h    |  77 ++--
>   drivers/net/ethernet/stmicro/stmmac/dwmac100.h     |   1 -
>   drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   3 +-
>   .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 111 +++--
>   drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  22 +-
>   drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |  39 +-
>   drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |  21 +
>   drivers/net/ethernet/stmicro/stmmac/enh_desc.c     | 226 +++++-----
>   drivers/net/ethernet/stmicro/stmmac/norm_desc.c    | 150 ++++---
>   drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |  32 +-
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   9 +-
>   .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  41 +-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 473 ++++++++++++---------
>   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |   4 +-
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  42 +-
>   include/linux/stmmac.h                             |  17 +-
>   20 files changed, 1016 insertions(+), 712 deletions(-)
>
