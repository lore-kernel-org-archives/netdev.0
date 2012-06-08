From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Thu, 07 Jun 2012 23:22:27 -0700 (PDT)
Message-ID: <20120607.232227.1902940919233969170.davem@davemloft.net>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	<20120607.230216.2014005732863772019.davem@davemloft.net>
	<1339136238.6001.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933621Ab2FHGW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 02:22:28 -0400
In-Reply-To: <1339136238.6001.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jun 2012 08:17:18 +0200

> On Thu, 2012-06-07 at 23:02 -0700, David Miller wrote:
> 
>> Hmmm, isn't that what qdisc_skb_cb is for?  And even private data is
>> explicitly allocated:
>> 
>> >  	unsigned char		data[24];
>> 
>> there. :-)
>> 
> 
> By the way, I notice data[] is not aligned on a long on 64bit arches.
> 
> This might break net/sched/sch_netem.c on some arches, since
> time_to_send is a u64.

Looks like we'll get the bonding queue mapping and fix this alignment
bug for free then :-)
