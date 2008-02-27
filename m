From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Wed, 27 Feb 2008 12:46:41 +0100
Message-ID: <47C54DA1.5070402@trash.net>
References: <47BAEE3B.7020502@trash.net>	 (sfid-20080219_145720_362430_7BA05F2C) <1204112235.3729.54.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50710 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbYB0LrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 06:47:05 -0500
In-Reply-To: <1204112235.3729.54.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
>     
>   
>>     Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 from you
>>     introduced a new field "da_synced" to struct dev_addr_list that is
>>     not properly initialized to 0. So when any of the current users (8021q,
>>     macvlan, mac80211) calls dev_mc_sync/unsync they mess the address
>>     list for both devices.
>>  
>> -	da = kmalloc(sizeof(*da), GFP_ATOMIC);
>> +	da = kzalloc(sizeof(*da), GFP_ATOMIC);
>>     
>
> Could this be the reason for us seeing "multicast address leakage"
> warnings?


I don't think so, the users field was already initialized properly
before. Is wireless using dev_unicast_sync or dev_mc_sync?

