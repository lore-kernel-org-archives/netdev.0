From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage
 for skb orig len instead of skb->cb[]
Date: Sat, 28 Feb 2015 15:08:30 -0500 (EST)
Message-ID: <20150228.150830.1726900309943339124.davem@davemloft.net>
References: <1424977624-649-5-git-send-email-eyal.birger@gmail.com>
	<20150228.142135.470339626705046722.davem@davemloft.net>
	<CAHsH6Guq33N755dcuNEmzgP06O=PBdy2Tzt5vSr-iRFoj4uGtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbbB1UIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 15:08:32 -0500
In-Reply-To: <CAHsH6Guq33N755dcuNEmzgP06O=PBdy2Tzt5vSr-iRFoj4uGtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Sat, 28 Feb 2015 21:39:34 +0200

> On Sat, Feb 28, 2015 at 9:21 PM, David Miller <davem@davemloft.net> wrote:
>> From: Eyal Birger <eyal.birger@gmail.com>
>> Date: Thu, 26 Feb 2015 21:07:01 +0200
>>
>>> As part of an effort to move skb->dropcount to skb->cb[], 4 bytes
>>> of additional room are needed in skb->cb[] in packet sockets.
>>>
>>> Store the skb original length in skb->dev instead of skb->cb[] for
>>> this purpose.
>>>
>>> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
>>
>> I'm a little confused, why is this even needed?
>>
>> packet_skb_cb is 24 bytes by my calculations, which is much
>> smaller than the cb[] size which is 48 bytes.
> 
> Note the BUILD_BUG_ON in packet_rcv().
> 
> packet_skb_cb may contain an address as large as MAX_ADDR_LEN (32)
> Therefore the required space is sizeof(packet_skb_cb) + MAX_ADDR_LEN - 8
> which is 48 bytes before this change.

So let's take a step back.

What link layer we support has 32-byte hardware addresses?

If the answer is lower than 32, we should use that value instead.
