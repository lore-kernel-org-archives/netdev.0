From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] tcp: fixing TLP's FIN recovery
Date: Tue, 07 Oct 2014 16:17:13 -0400 (EDT)
Message-ID: <20141007.161713.27716499707772337.davem@davemloft.net>
References: <1402585712-12103-1-git-send-email-per.hurtig@kau.se>
	<20140612.110611.584155630422154338.davem@davemloft.net>
	<CAKA=qzZ+L67Z4O7DY0hR_N=5VFSZ2_Dn0to+8WLqnpfgQg+00Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: per.hurtig@kau.se, eric.dumazet@gmail.com, panweiping3@gmail.com,
	nanditad@google.com, netdev@vger.kernel.org, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, ncardwell@google.com,
	sergei.shtylyov@cogentembedded.com
To: joshhunt00@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbaJGURP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:17:15 -0400
In-Reply-To: <CAKA=qzZ+L67Z4O7DY0hR_N=5VFSZ2_Dn0to+8WLqnpfgQg+00Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <joshhunt00@gmail.com>
Date: Tue, 7 Oct 2014 10:03:29 -0500

> On Thu, Jun 12, 2014 at 1:06 PM, David Miller <davem@davemloft.net> wrote:
>> From: Per Hurtig <per.hurtig@kau.se>
>> Date: Thu, 12 Jun 2014 17:08:32 +0200
>>
>>> Fix to a problem observed when losing a FIN segment that does not
>>> contain data.  In such situations, TLP is unable to recover from
>>> *any* tail loss and instead adds at least PTO ms to the
>>> retransmission process, i.e., RTO = RTO + PTO.
>>>
>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>
>> Applied, thanks.
> 
> Can we queue this up for stable? 2cd0d743b05e87 (tcp: fix
> tcp_match_skb_to_sack() for unaligned SACK at end of an skb) is
> already in stable and based on the changelog was put in place to fix a
> case that this patch introduced:
> 
> "This was visible now because the recently simplified TLP logic in
>  bef1909ee3ed1c ("tcp: fixing TLP's FIN recovery") could find that 0-byte
>  skb at the end of the write queue, and now that we do not check that
>  skb's length we could send it as a TLP probe."
> 
> However, the patch to fix TLP's FIN recovery is not in -stable.

Queued up for -stable, thanks.
