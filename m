From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 2/2] ipv4: flush ARP entries on device change
Date: Wed, 03 Mar 2010 16:20:13 +0200
Message-ID: <4B8E701D.7070300@iki.fi>
References: <1267624874-22326-1-git-send-email-timo.teras@iki.fi> <1267624874-22326-2-git-send-email-timo.teras@iki.fi> <4B8E6CC8.3080701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:18746 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188Ab0CCOUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:20:16 -0500
Received: by ey-out-2122.google.com with SMTP id 25so248372eya.19
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 06:20:14 -0800 (PST)
In-Reply-To: <4B8E6CC8.3080701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Timo Teras wrote:
>> If device flag IFF_NOARP is changed, we should flush the ARP cache as all
>> entries need to get refreshed.
>>
>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>> ---
>>  net/ipv4/arp.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
>> index c4dd135..036da92 100644
>> --- a/net/ipv4/arp.c
>> +++ b/net/ipv4/arp.c
>> @@ -1245,6 +1245,9 @@ static int arp_netdev_event(struct notifier_block *this, unsigned long event, vo
>>  		neigh_changeaddr(&arp_tbl, dev);
>>  		rt_cache_flush(dev_net(dev), 0);
>>  		break;
>> +	case NETDEV_CHANGE:
>> +		neigh_changeaddr(&arp_tbl, dev);
>> +		break;
> 
> It would be nice if we could restrict this to IFF_NOARP changes.

Yes. But I did not see any easy way to figure out which flags have changed.

Should we just keep a copy of the previous IFF_NOARP bit somewhere (where?).
Or did I miss something obvious?

- Timo
