From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] qlge: call ql_core_dump() only if dump memory was
 allocated.
Date: Fri, 20 Sep 2013 11:08:51 -0700
Message-ID: <1379700531.2301.2.camel@joe-AO722>
References: <20130920.120201.1305554403409938708.davem@davemloft.net>
	 <1379696386-29573-1-git-send-email-malahal@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Malahal Naineni <malahal@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0106.hostedemail.com ([216.40.44.106]:33130 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753135Ab3ITSIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:08:55 -0400
In-Reply-To: <1379696386-29573-1-git-send-email-malahal@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-20 at 11:59 -0500, Malahal Naineni wrote:
> Also changed a log message to indicate that memory was not allocated
> instead of memory not available!
[]
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
[]
> @@ -1274,11 +1274,13 @@ void ql_mpi_reset_work(struct work_struct *work)
>  		return;
>  	}
>  
> -	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
> -		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
> -		qdev->core_is_dumped = 1;
> -		queue_delayed_work(qdev->workqueue,
> -			&qdev->mpi_core_to_log, 5 * HZ);
> +	if (qdev->mpi_coredump) {
> +		if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
> +			netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
> +			qdev->core_is_dumped = 1;
> +			queue_delayed_work(qdev->workqueue,
> +				&qdev->mpi_core_to_log, 5 * HZ);
> +		}

This can be done without adding another indentation level

	if (qdev->mpi_coredump &&
	    !ql_core_dump(qdev, qdev->mpi_coredump)) {
