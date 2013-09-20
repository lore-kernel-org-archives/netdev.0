From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: call ql_core_dump() only if dump memory was
 allocated.
Date: Fri, 20 Sep 2013 14:50:03 -0400 (EDT)
Message-ID: <20130920.145003.1896896020428869929.davem@davemloft.net>
References: <20130920.120201.1305554403409938708.davem@davemloft.net>
	<1379696386-29573-1-git-send-email-malahal@us.ibm.com>
	<1379700531.2301.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: malahal@us.ibm.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488Ab3ITSuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:50:04 -0400
In-Reply-To: <1379700531.2301.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 20 Sep 2013 11:08:51 -0700

> On Fri, 2013-09-20 at 11:59 -0500, Malahal Naineni wrote:
>> Also changed a log message to indicate that memory was not allocated
>> instead of memory not available!
> []
>> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
> []
>> @@ -1274,11 +1274,13 @@ void ql_mpi_reset_work(struct work_struct *work)
>>  		return;
>>  	}
>>  
>> -	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
>> -		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
>> -		qdev->core_is_dumped = 1;
>> -		queue_delayed_work(qdev->workqueue,
>> -			&qdev->mpi_core_to_log, 5 * HZ);
>> +	if (qdev->mpi_coredump) {
>> +		if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
>> +			netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
>> +			qdev->core_is_dumped = 1;
>> +			queue_delayed_work(qdev->workqueue,
>> +				&qdev->mpi_core_to_log, 5 * HZ);
>> +		}
> 
> This can be done without adding another indentation level
> 
> 	if (qdev->mpi_coredump &&
> 	    !ql_core_dump(qdev, qdev->mpi_coredump)) {

Agreed.
