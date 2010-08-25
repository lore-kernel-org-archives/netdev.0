From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Wed, 25 Aug 2010 21:38:00 +0200
Message-ID: <20100825193800.GA9118@nuttenaction>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
 <1282762851-3612-2-git-send-email-greearb@candelatech.com>
 <201008252124.09917.arnd@arndb.de>
 <4C756EAF.9090704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39942 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751660Ab0HYTiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:38:03 -0400
Content-Disposition: inline
In-Reply-To: <4C756EAF.9090704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ben Greear | 2010-08-25 12:27:43 [-0700]:

>>I suppose we need to do something in macvtap to handle this as
>>well, right? A guest trying to send a frame through qemu
>>or vhost net into macvtap needs to be prevented from sending
>>more when we get into this path. Right now, we just ignore
>>the return value of macvlan_start_xmit.
>
>I have a similar, though slightly more complex, patch for 802.1q
>vlans, but I haven't looked at macvtap at all.
>
>If these two patches are accepted, I'll post the .1q patch as well.

I do not completely understand the benefit for macvlan. I think this BUSY logic
shifts functionality and make upper level code more complicated (e.g. handle
NET_XMIT_SUCCESS and skb bookkeeping). At the end it boils down to two
scenarios:

a) the congestion is temporary
b) the congestion is for a longer period

For a), a increased link queue length can bridge a longer period too. There is
no need to shift the logic in the upper layer. For b): at the end the upper
layer must also drop skb's - there is no alternative. Or require qemu other,
special handling? (e.g. sleep until the queue is free again).

For case a) the shift in the upper layers _can_ be superior because it can
dynamically increase the skb buffer, whatever. But why not implementing a more
clever, dynamic fifo. E.g. pfifo_dynamic (not really serious)? Is this
functionality qemu centric or are there any other use cases?

Hagen

