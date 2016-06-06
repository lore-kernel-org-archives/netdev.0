From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Reduce resource allocation in kdump
 kernel
Date: Mon, 06 Jun 2016 15:31:49 -0700 (PDT)
Message-ID: <20160606.153149.1705224523826590864.davem@davemloft.net>
References: <1464975345-12484-1-git-send-email-hariprasad@chelsio.com>
	<BY2PR12MB064802D9AB46EF297736F308C8590@BY2PR12MB0648.namprd12.prod.outlook.com>
	<CO2PR11MB008805A31B3921BF3C728F7A975A0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com, netdev@vger.kernel.org,
	nirranjan@chelsio.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbcFFWbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 18:31:51 -0400
In-Reply-To: <CO2PR11MB008805A31B3921BF3C728F7A975A0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sat, 4 Jun 2016 13:24:43 +0000

>> When is_kdump_kernel() is true, reduce our memory footprint by only using a
>> single "Queue Set" and Forcing Master so we can reinitialize the Firmware/Chip.
>> 
>> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ...
>>         if (q10g > netif_get_num_default_rss_queues())
>>                 q10g = netif_get_num_default_rss_queues();
>> 
>> +       /* Reduce memory usage in kdump environment by using only one queue
>> +        * and disable all offload.
>> +        */
>> +       if (is_kdump_kernel()) {
>> +               q10g = 1;
>> +               adap->params.offload = 0;
>> +       }
>> +
> 
> Sounds like a common issue that might interest other devices as well.
> Perhaps we should change netif_get_num_default_rss_queues() to return 1
> when called from a kdump kernel?

Yeah that might make sense.
