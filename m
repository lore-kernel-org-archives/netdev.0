From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: Reallocate headroom if it would overflow
 csum_start
Date: Thu, 11 Apr 2013 18:13:23 -0400 (EDT)
Message-ID: <20130411.181323.1651670003528345857.davem@davemloft.net>
References: <751a8e6e8f026ec11fbfa97347c0db352225f878.1365713735.git.tgraf@suug.ch>
	<1365718132.3887.186.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753708Ab3DKWN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 18:13:27 -0400
In-Reply-To: <1365718132.3887.186.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Apr 2013 15:08:52 -0700

> On Thu, 2013-04-11 at 22:57 +0200, Thomas Graf wrote:
>> If a TCP retransmission gets partially ACKed and collapsed multiple
>> times it is possible for the headroom to grow beyond 64K which will
>> overflow the 16bit skb->csum_start which is based on the start of
>> the headroom. It has been observed rarely in the wild with IPoIB due
>> to the 64K MTU.
>> 
>> Verify if the acking and collapsing resulted in a headroom exceeding
>> what csum_start can cover and reallocate the headroom if so.
>> 
>> A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
>> LLNL for helping out with the investigation and testing.
>> 
>> Reported-by: Jim Foraker <foraker1@llnl.gov>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
