From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH v2] [POWERPC] ucc_geth: Fix build break introduced by commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
Date: Mon, 15 Oct 2007 22:09:42 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B5916@zch01exm26.fsl.freescale.net>
References: <1192455830-1028-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>,
	<akpm@linux-foundation.org>, <jgarzik@pobox.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:43343 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160AbXJOOL7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 10:11:59 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l9FEA6CK015674
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 07:11:55 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l9FEA4QP021585
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 09:10:05 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1192455830-1028-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Medve Emilian-EMMEDVE1 
> Sent: Monday, October 15, 2007 9:44 PM
> To: akpm@linux-foundation.org; jgarzik@pobox.com; Li 
> Yang-r58472; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
> Cc: Medve Emilian-EMMEDVE1
> Subject: [PATCH v2] [POWERPC] ucc_geth: Fix build break 
> introduced by commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
> 
> drivers/net/ucc_geth.c: In function 'ucc_geth_rx':
> drivers/net/ucc_geth.c:3483: error: 'dev' undeclared (first 
> use in this function)
> drivers/net/ucc_geth.c:3483: error: (Each undeclared 
> identifier is reported only once
> drivers/net/ucc_geth.c:3483: error: for each function it appears in.)
> make[2]: *** [drivers/net/ucc_geth.o] Error 1
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>

Acked-by: Li Yang <leoli@freescale.com>

> ---
> 
> Here is a convenient link for the culprit patch: 
> http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.g
> it;a=commit;h=09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
> 
> netdev-2.6> scripts/checkpatch.pl 
> 0001-POWERPC-ucc_geth-Fix-build-break-introduced-by-co.patch
> Your patch has no obvious style problems and is ready for submission.
> 
>  drivers/net/ucc_geth.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c 
> index d00e7d4..bec413b 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -63,7 +63,7 @@
>  #define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
>  
>  void uec_set_ethtool_ops(struct net_device *netdev);
> -	
> +
>  static DEFINE_SPINLOCK(ugeth_lock);
>  
>  static struct {
> @@ -3454,9 +3454,12 @@ static int ucc_geth_rx(struct 
> ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
>  	u16 length, howmany = 0;
>  	u32 bd_status;
>  	u8 *bdBuffer;
> +	struct net_device * dev;
>  
>  	ugeth_vdbg("%s: IN", __FUNCTION__);
>  
> +	dev = ugeth->dev;
> +
>  	/* collect received buffers */
>  	bd = ugeth->rxBd[rxQ];
>  
> --
> 1.5.3.GIT
> 
