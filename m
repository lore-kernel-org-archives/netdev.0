From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gianfar: dont conditionally alloc Rx/Err irq
 structs
Date: Mon, 04 Feb 2013 21:08:26 -0500 (EST)
Message-ID: <20130204.210826.189711339365165792.davem@davemloft.net>
References: <1360007382-7876-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab3BECI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 21:08:27 -0500
In-Reply-To: <1360007382-7876-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon,  4 Feb 2013 14:49:42 -0500

> Commit ee873fda3bec7c668407b837fc5519eb961fcd37
> 
>     "gianfar: Pack struct gfar_priv_grp into three cachelines"
> 
> causes the following null dereference at driver init on sbc8548:
> 
>    libphy: Freescale PowerQUICC MII Bus: probed
>    Unable to handle kernel paging request for data at address 0x00000000
>    Faulting instruction address: 0xc01d6a38
>    Oops: Kernel access of bad area, sig: 11 [#1]
>    [...]
>    NIP [c01d6a38] gfar_parse_group+0x228/0x280
>    LR [c01d6a34] gfar_parse_group+0x224/0x280
>    Call Trace:
>    [ef82dd60] [c01d6a34] gfar_parse_group+0x224/0x280 (unreliable)
>    [ef82dd90] [c01d73a4] gfar_probe+0x284/0xfe0
> 
> The reason is that the commit also changed the allocation of the
> Rx and error handling irq structs to be skipped for !MQ_MG_MODE.
> In the !MQ_MG_MODE case, only the Tx irq struct is allocated.
> 
> Digging further, we see that MQ_MG_MODE is set only if we find
> the OF compatible string "fsl,etsec2".
> 
> A quick grep in the dts directory shows lots of boards that support
> Rx/Tx/Err, but without this specific compat string.  And hence they
> go after the unallocated Rx/Error structs and cause the above oops.
> 
> Hence such a change can not be deployed until all the dts files
> are updated and sufficiently deployed.  Further, the optimization
> is of limited value, since the kmalloc'd struct in question has only
> a single unsigned int, and an (IFNAMSIZ + 6) sized string.
> 
> Note that no changes to the freeing code are needed here, as it
> already did an unconditional free of Rx/Tx/Error gfar_irqinfo.
> 
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
