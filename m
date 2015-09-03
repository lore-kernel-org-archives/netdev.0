From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Thu, 03 Sep 2015 15:35:39 -0700 (PDT)
Message-ID: <20150903.153539.602528675900194363.davem@davemloft.net>
References: <20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
	<20150902.223254.456957929929322205.davem@davemloft.net>
	<20150903.150102.391475245.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: nemoto@toshiba-tops.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbbICWfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 18:35:40 -0400
In-Reply-To: <20150903.150102.391475245.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Date: Thu, 3 Sep 2015 15:01:02 +0900

> On Wed, 2 Sep 2015 22:32:54 -0700, David Miller <davem@davemloft.net> wrote:
>>> I think napi_gro_flush() can be called with irq enabled, so moving the
>>> spin_lock_irqsave() just before the __napi_complete() (or moving the
>>> __napi_complete() just after the spin_lock_irqsave()) would be better,
>>> right?
>> 
>> It should work, yes.
> 
> Thank you.  But I agree with Eric's last comment ("Calling
> napi_gro_flush() and __napi_complete() looks error prone."), and found
> that napi_complete_done() also checks NAPI_STATE_NPSVC to support
> NETPOLL.  These checks looks somewhat redundant but I like simple way
> unless it is really critical to performance.
> 
> So, please take original fix as is.

Fair enough, applied and queued up for -stable.
