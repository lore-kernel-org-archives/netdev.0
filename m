From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Wed, 27 Feb 2008 13:42:00 +0100
Message-ID: <47C55A98.7000304@trash.net>
References: <47BAEE3B.7020502@trash.net>	 (sfid-20080219_145720_362430_7BA05F2C) <1204112235.3729.54.camel@johannes.berg>	 <47C54DA1.5070402@trash.net> <1204115674.6309.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep32-int.chello.at ([62.179.121.50]:47086 "EHLO
	viefep32-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576AbYB0MmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 07:42:08 -0500
In-Reply-To: <1204115674.6309.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
>>> Could this be the reason for us seeing "multicast address leakage"
>>> warnings?
>>
>> I don't think so, the users field was already initialized properly
>> before. Is wireless using dev_unicast_sync or dev_mc_sync?
> 
> dev_mc_sync(), we sync all multicast addresses of all interfaces to the
> master netdev to have a single consistent list. There used to be a
> custom implementation of that but I replaced it.


I can't see how this bug could be responsible, assuming da_synced
intially contained a non-zero value it might forget to sync an
address, but still try to delete it when unsyncing. __dev_addr_delete
will simply do nothing in this case. But I guess the patch is still
worth trying.

