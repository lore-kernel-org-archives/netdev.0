From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: bug fix Fast Open client retransmission
Date: Fri, 07 Dec 2012 14:41:08 -0500 (EST)
Message-ID: <20121207.144108.1794765164441829140.davem@davemloft.net>
References: <1354819532-15676-1-git-send-email-ycheng@google.com>
	<CADVnQymE7ubywMytDCabQ=3gMWkp=gVrHZke0HpiufQNbF=1KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, nanditad@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LGTlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:41:10 -0500
In-Reply-To: <CADVnQymE7ubywMytDCabQ=3gMWkp=gVrHZke0HpiufQNbF=1KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 6 Dec 2012 14:50:58 -0500

> On Thu, Dec 6, 2012 at 1:45 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> If SYN-ACK partially acks SYN-data, the client retransmits the
>> remaining data by tcp_retransmit_skb(). This increments lost recovery
>> state variables like tp->retrans_out in Open state. If loss recovery
>> happens before the retransmission is acked, it triggers the WARN_ON
>> check in tcp_fastretrans_alert(). For example: the client sends
>> SYN-data, gets SYN-ACK acking only ISN, retransmits data, sends
>> another 4 data packets and get 3 dupacks.
>>
>> Since the retransmission is not caused by network drop it should not
>> update the recovery state variables. Further the server may return a
>> smaller MSS than the cached MSS used for SYN-data, so the retranmission
>> needs a loop. Otherwise some data will not be retransmitted until timeout
>> or other loss recovery events.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied.
