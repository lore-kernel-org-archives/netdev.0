From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: Return from ibmvnic_resume if not in
 VNIC_OPEN state
Date: Tue, 20 Jun 2017 12:36:23 -0500
Message-ID: <3d0baa3a-6c7a-8c12-f695-ec73c15159f2@linux.vnet.ibm.com>
References: <b9b5f82f-c59b-4816-b745-31080c6cdf78@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: John Allen <jallen@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41105 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750923AbdFTRg2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:36:28 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5KHXoD1120512
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 13:36:28 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b6mknt6x2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 13:36:28 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 20 Jun 2017 13:36:27 -0400
In-Reply-To: <b9b5f82f-c59b-4816-b745-31080c6cdf78@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/19/2017 11:27 AM, John Allen wrote:
> If the ibmvnic driver is not in the VNIC_OPEN state, return from
> ibmvnic_resume callback. If we are not in the VNIC_OPEN state, interrupts
> may not be initialized and directly calling the interrupt handler will
> cause a crash.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Reviewed-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

> ---
> diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
> index 722daf5..0135095 100644
> --- a/drivers/net/ethernet/ibm/ibmvnic.c
> +++ b/drivers/net/ethernet/ibm/ibmvnic.c
> @@ -3859,6 +3859,9 @@ static int ibmvnic_resume(struct device *dev)
>  	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
>  	int i;
> 
> +	if (adapter->state != VNIC_OPEN)
> +		return 0;
> +
>  	/* kick the interrupt handlers just in case we lost an interrupt */
>  	for (i = 0; i < adapter->req_rx_queues; i++)
>  		ibmvnic_interrupt_rx(adapter->rx_scrq[i]->irq,
> 
