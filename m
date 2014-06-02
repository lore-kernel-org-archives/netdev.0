From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/6] be2net: skip multicast promiscuos setting
 in already set
Date: Mon, 02 Jun 2014 14:51:22 +0400
Message-ID: <538C572A.1060008@cogentembedded.com>
References: <1401456988-11395-1-git-send-email-sathya.perla@emulex.com> <1401456988-11395-2-git-send-email-sathya.perla@emulex.com> <53888CD0.50403@cogentembedded.com> <CF9D1877D81D214CB0CA0669EFAE020C56C3651C@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:41845 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbaFBKvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 06:51:25 -0400
Received: by mail-la0-f44.google.com with SMTP id hr17so2497267lab.31
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 03:51:23 -0700 (PDT)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C56C3651C@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-06-2014 8:44, Sathya Perla wrote:

>>> From: Kalesh AP <kalesh.purayil@emulex.com>

>>> Set mc-promisc (multicast promiscuous) mode on an interface, only if it is
>>> *not already* in that mode.

>>> Also removed logs that report interface being set to multicast
>>> promiscous mode. In an earlier comment on the netdev list such log
>>> messages
>>> were deemed unnecessary as this behaviour is common across most of the
>>> ethernet drivers.

>>> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
>>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

>> [...]

>>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
>> b/drivers/net/ethernet/emulex/benet/be_main.c
>>> index e1d445d..9116d5e 100644
>>> --- a/drivers/net/ethernet/emulex/benet/be_main.c
>>> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> [...]
>>> @@ -1244,15 +1242,22 @@ static void be_set_rx_mode(struct net_device
>> *netdev)
>>>    	}
>>>
>>>    	status = be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
>>> -
>>> -	/* Set to MCAST promisc mode if setting MULTICAST address fails */
>>> -	if (status) {
>>> -		dev_info(&adapter->pdev->dev,
>>> -			 "Exhausted multicast HW filters.\n");
>>> -		dev_info(&adapter->pdev->dev,
>>> -			 "Disabling HW multicast filtering.\n");
>>> -		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
>>> +	if (!status) {
>>> +		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
>>> +			adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;

>>      Why not just clear it without prior check?

> Yes, can be done. But, what is wrong with clearing the flag after the check ?

    More code, and not very justified, IMHO.

WBR, Sergei
