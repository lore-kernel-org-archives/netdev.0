From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/7] : myri10ge Fix possible causing oops of
	net_rx_action
Date: Wed, 12 Dec 2007 14:00:57 +0530
Message-ID: <1197448257.4710.31.camel@subratamodak.linux.ibm.com>
References: <002801c83c73$af10f990$9c94fea9@jason>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, help@myri.com
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55582 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492AbXLLIbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 03:31:01 -0500
In-Reply-To: <002801c83c73$af10f990$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would you like to submit the Driver Test Cases to LTP ? Or, if you have
your Driver test cases written in C, we can port to LTP and have it
inside the LTP package.
You can also check out the following links for more info, and can always
ping me for anything:
http://ltp.cvs.sourceforge.net/ltp/ltp/testcases/kernel/device-drivers/,
http://ltp.sourceforge.net/documentation/how-to/ltp.php?

Regards--
Subrata
(LTP Maintainer)

On Wed, 2007-12-12 at 13:01 +0900, Joonwoo Park wrote:
> [NETDEV]: myri10ge Fix possible causing oops of net_rx_action
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
> index 8def865..57311ed 100644
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -1242,6 +1242,8 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
>  	if (work_done < budget || !netif_running(netdev)) {
>  		netif_rx_complete(netdev, napi);
>  		put_be32(htonl(3), mgp->irq_claim);
> +		if (unlikely(work_done == napi->weight))
> +			return work_done - 1;
>  	}
>  	return work_done;
>  }
> ---
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

