From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Fri, 14 Aug 2009 16:41:23 -0700 (PDT)
Message-ID: <20090814.164123.36875657.davem@davemloft.net>
References: <4A855DE2.2000907@gmail.com>
	<20090814163644.0cc8974f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39035
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754306AbZHNXlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:41:12 -0400
In-Reply-To: <20090814163644.0cc8974f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 14 Aug 2009 16:36:44 -0700

> On Fri, 14 Aug 2009 14:51:46 +0200
> Roel Kluin <roel.kluin@gmail.com> wrote:
> 
>> @@ -663,9 +663,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
>>  	} else {
>>  		if (skb->data[pkt_len] & FrameRdo)
>>  			dev->stats.rx_fifo_errors++;
>> -		else if (!(skb->data[pkt_len] | ~FrameCrc))
>> +		else if (!(skb->data[pkt_len] & ~FrameCrc))
>>  			dev->stats.rx_crc_errors++;
> 
> that's
> 
> 	if (!(x & 0xffffffdf))
> 
> which seems peculiar.  Should it have been
> 
> 	else if (skb->data[pkt_len] & FrameCrc)
> 
> or
> 
> 	else if (!(skb->data[pkt_len] & FrameCrc))

Indeed, I can't tell which variant would be correct.

I'm reverting until someone with a datasheet for this chip speaks up
:-)
