From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Multiqueue macvtap driver
Date: Sun, 01 Aug 2010 00:34:06 -0700 (PDT)
Message-ID: <20100801.003406.02275545.davem@davemloft.net>
References: <20100731135743.3072.99933.sendpatchset@krkumar2.in.ibm.com>
	<1280603907.13192.353.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, arnd@arndb.de, netdev@vger.kernel.org,
	mst@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48707
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754039Ab0HAHds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Aug 2010 03:33:48 -0400
In-Reply-To: <1280603907.13192.353.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 31 Jul 2010 20:18:27 +0100

> On Sat, 2010-07-31 at 19:27 +0530, Krishna Kumar wrote:
> [...]
>> @@ -136,39 +158,68 @@ static void macvtap_put_queue(struct mac
>>  }
>>  
>>  /*
>> - * Since we only support one queue, just dereference the pointer.
>> + * Select a queue based on the rxq of the device on which this packet
>> + * arrived. If the incoming device is not mq, then use our cpu number
>> + * to select a queue. vlan->numvtaps is cached in case it changes
>> + * during the execution of this function.
>>   */
> [...]
> 
> This can result in reordering if a single-queue device's RX interrupt's
> CPU affinity is changed.  We generally try to avoid that.  You should
> really use or generate a flow hash.  There is code for this in
> net/core/dev.c:get_rps_cpu() which could be factored out into a separate
> function.

Agreed.
