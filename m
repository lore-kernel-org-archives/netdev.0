From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH net-next v2 2/3] sh_eth: add support RMIIMODE register
Date: Wed, 15 May 2013 09:51:17 +0900
Message-ID: <20130515005117.GC12246@verge.net.au>
References: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au>
 <1368499073-21975-3-git-send-email-horms+renesas@verge.net.au>
 <519240C7.1060406@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34683 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758701Ab3EOAvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 20:51:22 -0400
Content-Disposition: inline
In-Reply-To: <519240C7.1060406@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 14, 2013 at 05:48:55PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 14-05-2013 6:37, Simon Horman wrote:
> 
> >This change is motivated by the lager board which uses the r8a7790 SoC,
> >an R-Car SoC. For this board setting the RMIIMODE register is necessary.
> 
> >This patch assumes this is valid for all R-Car SoCs.
> 
>    No, RMIIMODE register is not documented on R8A7778/9 SoCs and
> this location is described as reserved. How's it called in R8A7790
> manual, CXR15?

It appears to be undocumented in the R8A7790 I have.
Empirically it seems necessary for the lager/R8A7790.
To be honest I am entirely unsure of its relevance to other SoCs.

I wonder if a better approach would be to add a flag to platform
data rather than struct sh_eth_cpu_data. This would allow the register
to only be accessed on boards where it is known to be useful.

> 
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> >--
> 
>    Missed a dash here.
> 
> >v2
> >* Split from patch to add r8a7790 support to driver (ifdef nastiness)
> >* As suggested by Sergei Shtylyov
> >   - Add a field to struct sh_eth_cpu_data to indicate if the
> >     rmiimode register is present. This replaces an extremely ugly ifdef.
> >---
> >  drivers/net/ethernet/renesas/sh_eth.c | 5 +++++
> >  drivers/net/ethernet/renesas/sh_eth.h | 2 ++
> >  2 files changed, 7 insertions(+)
> 
> >diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> >index 016cf80..ff5613d 100644
> >--- a/drivers/net/ethernet/renesas/sh_eth.c
> >+++ b/drivers/net/ethernet/renesas/sh_eth.c
> >@@ -190,6 +190,7 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
> >  	[RMCR]		= 0x0258,
> >  	[TFUCR]		= 0x0264,
> >  	[RFOCR]		= 0x0268,
> >+	[RMIIMODE]      = 0x026c,
> >  	[FCFTR]		= 0x0270,
> >  	[TRIMD]		= 0x027c,
> >  };
> 
> WBR, Sergei
> 
