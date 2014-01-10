From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] be2net: Need a delay before processing CQE
 after 2nd mbox register write
Date: Fri, 10 Jan 2014 15:11:09 -0500 (EST)
Message-ID: <20140110.151109.1275347758815420234.davem@davemloft.net>
References: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh.purayil@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbaAJULL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:11:11 -0500
In-Reply-To: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Wed, 8 Jan 2014 14:52:02 +0530

> Due to Host platform synchronization issues between the mbox RDY bit polled
> status and the completion of the DMA for the CQE, it is preferable that the
> Host always wait for the RDY bit to transition to 1 after the 2nd mbox register
> write and always follow that with a short wait for the valid bit in the CQE,
> before processing the CQE.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
> index 94c35c8..78560f2 100644
> --- a/drivers/net/ethernet/emulex/benet/be_cmds.c
> +++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
> @@ -502,6 +502,9 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
>  	if (status != 0)
>  		return status;
>  
> +	/* Need a delay before processing CQE after 2nd mbox register write */
> +	udelay(1);
> +

Like others, I find his delay being used to fix the stated problem as questionable,
at best.

Either find a more appropriate way to fix this problem, or elaborate (in the commit
message), why this is really a suitable way to handle this.
