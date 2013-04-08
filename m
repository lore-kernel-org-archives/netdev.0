From: phil.edworthy@renesas.com
Subject: Re: [PATCH 2/2] sh_eth: add R-Car support for real
Date: Mon, 08 Apr 2013 15:40:01 +0100
Message-ID: <OF927F8D41.407FE3E6-ON80257B47.004FDFDA-80257B47.005090A7@eu.necel.com>
References: <201303290051.32106.sergei.shtylyov@cogentembedded.com>
 <20130408023936.GA1643@verge.net.au> <20130408090451.GC8917@verge.net.au>
 <5162C9EA.6060005@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Simon Horman <horms@verge.net.au>, linux-sh@vger.kernel.org,
	netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <5162C9EA.6060005@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

> >>> Commit d0418bb7123f44b23d69ac349eec7daf9103472f (net: sh_eth: 
> Add eth support
> >>> for R8A7779 device) was a failed attempt to add support for one 
> of members of
> >>> the R-Car SoC family.  That's for three reasons: it treated 
> R8A7779 the  same
> >>> as SH7724 except including quite dirty hack adding ECMR_ELB  bit
> to the mask
> >>> in sh_eth_set_rate() while not removing ECMR_RTM bit (despite 
> it's reserved in
> >>> R-Car Ether), and it didn't add a new register offset array 
> despite the closest
> >>> SH_ETH_REG_FAST_SH4 mapping differs by 0x200 to the offsets all 
> the R-Car Ether
> >>> registers have, and also some of the registers in this old 
> mapping don't exist
> >>> on R-Car Ether (due to this, SH7724's 'sh_eth_my_cpu_data' 
> structure is not
> >>> adequeate for R-Car too).  Fix all these shortcomings, restoringthe 
SH7724
> >>> related section to its pristine state...
> 
> >>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> >> Hi Sergei,
> 
> >> thanks for this and sorry for not noticing it earlier.
> >> I will try exercising it on the r8a7790 lager.
> 
> > I am having a little trouble getting bringing up a link on the
> > r8a7790 lager. I wonder if:
> 
> > * You know of any sh_eth side changes that need to be made,
> >    other than adding r8a7790 obvious ones relating to adding
> >    ARCH_R8A7790 wherever ARCH_R8A7779 is found.
> 
>     Unfortunately, the only datasheet for R8A7790 Ether I have is 
inJapanese. 
> And I don't have the board info either. :-(
> 
> > * You have any sample board code for the marzen/r8a7779 or
> >    bockw/r8a7778 handy.
> 
>     On Marzen the driver simply doesn't work right (and I don't evenhave 
the 
> datasheet for the Ethernet daughter board that I have, only for some 
other 
> type of board), on the BOCK-W the driver works but I have only tested it 
with 
> the version 1 of Morimoto-san's R8A7778/BOCK-W patches (which included 
pinmux
> support), so this patch doesn't compile anymore with the current 
> renesas.git/next. With BOCK-W you need to set 'no_ether_link' in 
theplatform 
> data since the Ether's LINK signal is connected to PHY's link/
> activity LED output.

Thanks for the patch. When I added r8a7779 support, I had a rather poor 
manual with a lot of information missing. I submitted the patch once I got 
the driver working on a Marzen board, with an REE Expansion Board.

One of the main changes you have made is adjusting the offset of the 
control registers. When I did this work originally, I just assumed that 
the base address start at 0x1DE00200, i.e. it included the 0x200 offset. 
This made sense as the registers are then identically positioned to sh4a.

Regards
Phil
