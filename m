From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bonding: don't increase rx_dropped after processing
 LACPDUs
Date: Fri, 04 May 2012 10:53:00 -0400 (EDT)
Message-ID: <20120504.105300.372146763296364588.davem@davemloft.net>
References: <20120504121935.GC32665@midget.suse.cz>
	<1336136696.3752.320.camel@edumazet-glaptop>
	<20120504132824.GD32665@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab2EDOzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:55:17 -0400
In-Reply-To: <20120504132824.GD32665@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 4 May 2012 15:28:24 +0200

> On Fri, May 04, 2012 at 03:04:56PM +0200, Eric Dumazet wrote:
>> On Fri, 2012-05-04 at 14:19 +0200, Jiri Bohac wrote:
>> >  		if (likely(nskb)) {
>> > -			recv_probe(nskb, bond, slave);
>> > +			ret = recv_probe(nskb, bond, slave);
>> >  			dev_kfree_skb(nskb);
>> > +			if (ret == RX_HANDLER_CONSUMED) {
>> > +				kfree_skb(skb);
>> 
>> consume_skb(skb) to not fool drop_monitor/dropwatch ?
> 
> Thanks, fixed below:

You're doing the patch-as-reply thing again.
