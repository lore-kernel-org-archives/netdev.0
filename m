From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 2/7] amd-xgbe: Add netif_msg_* support for
 driver messages
Date: Tue, 12 May 2015 15:03:14 -0500
Message-ID: <55525C82.9090009@amd.com>
References: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
	 <20150512192242.14091.56225.stgit@tlendack-t1.amdoffice.net>
 <1431459888.2884.87.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0101.outbound.protection.outlook.com ([157.56.111.101]:38400
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751726AbbELUD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 16:03:26 -0400
In-Reply-To: <1431459888.2884.87.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2015 02:44 PM, Joe Perches wrote:
> On Tue, 2015-05-12 at 14:22 -0500, Tom Lendacky wrote:
>> Add support for the network interface message level settings for
>> determining whether to issue some of the driver messages.
>
> []
>
>> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
> []
>> @@ -150,9 +150,14 @@ static int xgbe_dcb_ieee_setets(struct net_device *netdev,
>>   	tc_ets = 0;
>>   	tc_ets_weight = 0;
>>   	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
>> -		DBGPR("  TC%u: tx_bw=%hhu, rx_bw=%hhu, tsa=%hhu\n", i,
>> -		      ets->tc_tx_bw[i], ets->tc_rx_bw[i], ets->tc_tsa[i]);
>> -		DBGPR("  PRIO%u: TC=%hhu\n", i, ets->prio_tc[i]);
>> +		if (netif_msg_drv(pdata)) {
>> +			netdev_dbg(netdev,
>> +				   "TC%u: tx_bw=%hhu, rx_bw=%hhu, tsa=%hhu\n",
>> +				   i, ets->tc_tx_bw[i], ets->tc_rx_bw[i],
>> +				   ets->tc_tsa[i]);
>
> These might be more concise and work a bit easier
> with dynamic_debug using
>
> 	netif_dbg(priv, type, netdev, fmt, ...)
>
> like:
>
> 		netif_dbg(pdata, drv, netdev,
> 			  "TC%u: tx_bw=%hhu, rx_bw=%hhu, tsa=%hhu\n",
> 			  i, ets->tc_tx_bw[i], ets->tc_rx_bw[i], ets->tc_tsa[i]);
>
>

I didn't realize that interface was there.  I'll convert them over
over to the netif_ format.  Thanks for the pointer.

Tom
