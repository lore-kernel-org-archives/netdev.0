From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: call tcp_replace_ts_recent() from tcp_ack()
Date: Fri, 19 Apr 2013 14:22:38 -0400 (EDT)
Message-ID: <20130419.142238.1129853033656607981.davem@davemloft.net>
References: <1366384390.16391.17.camel@edumazet-glaptop>
	<1366391988.16391.33.camel@edumazet-glaptop>
	<CADVnQynm+Je=FZ-X0fVT9zSpxdUjA+ANWmdAT0ziSNuJG=o1dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab3DSSWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:22:41 -0400
In-Reply-To: <CADVnQynm+Je=FZ-X0fVT9zSpxdUjA+ANWmdAT0ziSNuJG=o1dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Fri, 19 Apr 2013 13:31:58 -0400

> On Fri, Apr 19, 2013 at 1:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> commit bd090dfc634d (tcp: tcp_replace_ts_recent() should not be called
>> from tcp_validate_incoming()) introduced a TS ecr bug in slow path
>> processing.
>>
>> 1 A > B P. 1:10001(10000) ack 1 <nop,nop,TS val 1001 ecr 200>
>> 2 B < A . 1:1(0) ack 1 win 257 <sack 9001:10001,TS val 300 ecr 1001>
>> 3 A > B . 1:1001(1000) ack 1 win 227 <nop,nop,TS val 1002 ecr 200>
>> 4 A > B . 1001:2001(1000) ack 1 win 227 <nop,nop,TS val 1002 ecr 200>
>>
>> (ecr 200 should be ecr 300 in packets 3 & 4)
>>
>> Problem is tcp_ack() can trigger send of new packets (retransmits),
>> reflecting the prior TSval, instead of the TSval contained in the
>> currently processed incoming packet.
>>
>> Fix this by calling tcp_replace_ts_recent() from tcp_ack() after the
>> checks, but before the actions.
>>
>> Reported-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
>> ---
>> v2: use FLAG_UPDATE_TS_RECENT in tcp_rcv_state_process() as well
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks everyone.
