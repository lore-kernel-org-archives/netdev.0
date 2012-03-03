From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: don't fragment SACKed skbs in tcp_mark_head_lost()
Date: Sat, 03 Mar 2012 14:58:46 -0500 (EST)
Message-ID: <20120303.145846.1285582356848239241.davem@davemloft.net>
References: <1330760211-25785-1-git-send-email-ncardwell@google.com>
	<CAB_+Fg6x=0jFVysUK8stU1YEL4NGqid7h_XKfRW7BVVeYp3bcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, ycheng@google.com, therbert@google.com
To: nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab2CCT7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 14:59:24 -0500
In-Reply-To: <CAB_+Fg6x=0jFVysUK8stU1YEL4NGqid7h_XKfRW7BVVeYp3bcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nandita Dukkipati <nanditad@google.com>
Date: Sat, 3 Mar 2012 10:03:56 -0800

> On Fri, Mar 2, 2012 at 11:36 PM, Neal Cardwell <ncardwell@google.com> wrote:
>>
>> In tcp_mark_head_lost() we should not attempt to fragment a SACKed skb
>> to mark the first portion as lost. This is for two primary reasons:
>>
>> (1) tcp_shifted_skb() coalesces adjacent regions of SACKed skbs. When
>> doing this, it preserves the sum of their packet counts in order to
>> reflect the real-world dynamics on the wire. But given that skbs can
>> have remainders that do not align to MSS boundaries, this packet count
>> preservation means that for SACKed skbs there is not necessarily a
>> direct linear relationship between tcp_skb_pcount(skb) and
>> skb->len. Thus tcp_mark_head_lost()'s previous attempts to fragment
>> off and mark as lost a prefix of length (packets - oldcnt)*mss from
>> SACKed skbs were leading to occasional failures of the WARN_ON(len >
>> skb->len) in tcp_fragment() (which used to be a BUG_ON(); see the
>> recent "crash in tcp_fragment" thread on netdev).
>>
>> (2) there is no real point in fragmenting off part of a SACKed skb and
>> calling tcp_skb_mark_lost() on it, since tcp_skb_mark_lost() is a NOP
>> for SACKed skbs.
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> 
> Acked-by: Nandita Dukkipati <nanditad@google.com>

Applied and queued up for -stable, thanks everyone.
