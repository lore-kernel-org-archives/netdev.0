From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2]: [NET_SCHED]: Make all rate based scheduler work
 with TSO.
Date: Tue, 04 Sep 2007 18:23:26 +0200
Message-ID: <46DD867E.6020307@trash.net>
References: <1188562975.18622.11.camel@localhost.localdomain>	<46D9103B.7090905@trash.net>	<Pine.LNX.4.61.0709012325080.29796@ask.diku.dk> <20070903233456.0e738183.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, jdb@comx.dk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45128 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbXIDQYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 12:24:20 -0400
In-Reply-To: <20070903233456.0e738183.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink wrote:
> On Sat, 1 Sep 2007, Jesper Dangaard Brouer wrote:
>
>>On Sat, 1 Sep 2007, Patrick McHardy wrote:
>>
>>>
>>>It still won't work properly with TSO (TBF for example already drops
>>>oversized packets during ->enqueue), but its a good cleanup anyway.
>>
>>Then lets call it a cleanup of the L2T macros.  In the next step we will 
>>fix the different schedulers, to use the ability to lookup larger sized 
>>packets. (I did notice the TBF scheduler would drop oversized packets).
> 
> 
> Hmmm.  I guess this is also why TBF doesn't seem to work with 9000 byte
> jumbo frames.
> 
> [root@lang4 ~]# tc qdisc add dev eth2 root tbf rate 2gbit buffer 5000000 limit 18000


Yes, you need to specify the MTU on the command line for
jumbo frames.
