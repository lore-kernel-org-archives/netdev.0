From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Wed, 28 Dec 2011 13:09:08 -0500 (EST)
Message-ID: <20111228.130908.182833189468208987.davem@davemloft.net>
References: <20111227095635.19087752@nehalam.linuxnetplumber.net>
	<20111228074143.GA8041@florz.florz.dyndns.org>
	<20111228092714.0a6d5f80@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florz@florz.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118Ab1L1SKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:10:20 -0500
In-Reply-To: <20111228092714.0a6d5f80@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 28 Dec 2011 09:27:14 -0800

> On Wed, 28 Dec 2011 08:41:43 +0100
> Florian Zumbiehl <florz@florz.de> wrote:
> 
>> Hi,
>> 
>> > > > diff --git a/drivers/net/skge.c b/drivers/net/skge.c
>> > > > index f4be5c7..cd968e5 100644
>> > > > --- a/drivers/net/skge.c
>> > > > +++ b/drivers/net/skge.c
>> > > > @@ -4046,6 +4046,7 @@ static int skge_resume(struct device *dev)
>> > > >  				dev_close(dev);
>> > > >  				goto out;
>> > > >  			}
>> > > > +			skge_set_multicast(dev);
>> > > >  		}
>> > > >  	}
>> > > >  out:
>> > 
>> > Right idea, but it needs to be done in a different spot to catch
>> > all the other device restart cases like changing settings.
>> 
>> Roughly like this maybe? (Successfully tested with an MTU change ...)
>> 
>> Florian
>> 
>> ---------------------------------------------------------------------------
>> skge: restore rx multicast filter on resume
>> 
>> Signed-off-by: Florian Zumbiehl <florz@florz.de>
>> 
>> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
>> index f4be5c7..8f985a8 100644
>> --- a/drivers/net/skge.c
>> +++ b/drivers/net/skge.c
>> @@ -2587,6 +2587,9 @@ static int skge_up(struct net_device *dev)
>>  	spin_unlock_irq(&hw->hw_lock);
>>  
>>  	napi_enable(&skge->napi);
>> +
>> +	skge_set_multicast(dev);
>> +
>>  	return 0;
>>  
>>   free_rx_ring:
> 
> Looks good. That is (basically) the same as the patch I was testing.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Florian, please formally resubmit this with proper changelog and
Stephen's ack.

Thanks.
