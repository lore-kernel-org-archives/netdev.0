From: David Miller <davem@davemloft.net>
Subject: Re: bonding: don't increase rx_dropped after processing LACPDUs
Date: Wed, 02 May 2012 19:41:05 -0400 (EDT)
Message-ID: <20120502.194105.1211756092128572035.davem@davemloft.net>
References: <20120502202309.GA25355@midget.suse.cz>
	<1335991009.22133.639.camel@edumazet-glaptop>
	<20120502205118.GB25355@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab2EBXmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 19:42:19 -0400
In-Reply-To: <20120502205118.GB25355@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Wed, 2 May 2012 22:51:18 +0200

> On Wed, May 02, 2012 at 10:36:49PM +0200, Eric Dumazet wrote:
>> > +			if (ret == RX_HANDLER_CONSUMED)
>> > +				kfree_skb(skb);
>> 
>> After this point, you have use after free :
>> 
>> if (bond_should_deliver_exact_match(skb, slave, bond)) { 
>> 	...
>> }
>> skb->dev = bond->dev;
> 
> Thanks for spotting this! Let's just return immediately at that
> point. Fixed version below:
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Please don't do this.

When you post a fixed version of a patch, post it with the full
proper commit message and signoff.

I'm not going to go back to your original posting and put that
commit message from there into the fixed patch.  That's your
job as a patch submitter, not mine.
