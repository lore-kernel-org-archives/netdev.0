From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net] cxgb4: ptp_clock_register() returns error pointers
Date: Tue, 11 Jul 2017 22:20:00 +0200
Message-ID: <20170711202000.enehgnr4mn54uoug@localhost.localdomain>
References: <1499783078-4706-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        dan.carpenter@oracle.com, atul.gupta@chelsio.com
To: Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:36110 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932351AbdGKUUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:20:05 -0400
Received: by mail-wr0-f172.google.com with SMTP id c11so4402769wrc.3
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 13:20:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1499783078-4706-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 11, 2017 at 07:54:38PM +0530, Ganesh Goudar wrote:
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
> index 50517cf..06c0de4 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
> @@ -441,7 +441,7 @@ void cxgb4_ptp_init(struct adapter *adapter)
>  
>  	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
>  						&adapter->pdev->dev);
> -	if (!adapter->ptp_clock) {
> +	if (IS_ERR_OR_NULL(adapter->ptp_clock)) {

But here you also need

		adapter->ptp_clock = NULL;

>  		dev_err(adapter->pdev_dev,
>  			"PTP %s Clock registration has failed\n", __func__);
>  		return;

because later on you have:

void cxgb4_ptp_stop(struct adapter *adapter)
{
	...

	if (adapter->ptp_clock) {
		ptp_clock_unregister(adapter->ptp_clock);
		adapter->ptp_clock = NULL;
	}
}

Thanks,
Richard
