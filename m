From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] bridge: inherit slave devices needed_headroom
Date: Thu, 22 Aug 2013 13:06:35 -0700 (PDT)
Message-ID: <20130822.130635.86687384282537453.davem@davemloft.net>
References: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
	<20130821215829.1d65d38e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, vyasevic@redhat.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab3HVUGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 16:06:36 -0400
In-Reply-To: <20130821215829.1d65d38e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 21 Aug 2013 21:58:29 -0700

> On Tue, 20 Aug 2013 10:21:45 +0100
> "Florian Fainelli" <f.fainelli@gmail.com> wrote:
> 
>> Some slave devices may have set a dev->needed_headroom value which is
>> different than the default one, most likely in order to prepend a
>> hardware descriptor in front of the Ethernet frame to send. Whenever a
>> new slave is added to a bridge, ensure that we update the
>> needed_headroom value accordingly to account for the slave
>> needed_headroom value.
>> 
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  net/bridge/br_if.c | 3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index aa6c9a8..c41d5fb 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -383,6 +383,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>>  
>>  	netdev_update_features(br->dev);
>>  
>> +	if (br->dev->needed_headroom < dev->needed_headroom)
>> +		br->dev->needed_headroom = dev->needed_headroom;
>> +
>>  	spin_lock_bh(&br->lock);
>>  	changed_addr = br_stp_recalculate_bridge_id(br);
>>  
> 
> I am okay with this but it only helps locally generated traffic
> which is the minority on most bridge devices. It does nothing for the case
> where one port needs more headroom than the packet received on the
> other port. That is why a device has to always work when it receives
> a packet with less headroom, usually by copying.
> 

Right so this is basically an optimization.

Florian please submit this formally as a non-RFC patch so Stephen
can ACK it and I can apply it, thanks.
