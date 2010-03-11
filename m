From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 22:07:07 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003112205360.24500@obet.zrqbmnf.qr>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de> <1268337450-6749-4-git-send-email-jengelh@medozas.de> <20100311121239.14944fd5@nehalam> <20100311.122639.258785986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:60558 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab0CKVHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 16:07:10 -0500
In-Reply-To: <20100311.122639.258785986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2010-03-11 21:26, David Miller wrote:
>> On Thu, 11 Mar 2010 20:57:29 +0100
>> Jan Engelhardt <jengelh@medozas.de> wrote:
>> 
>>> `ip -s link` shows interface counters truncated to 32 bit. This is
>>> because interface statistics are transported only in 32-bit quantity
>>> to userspace. This commit adds a new IFLA_STATS64 attribute that
>>> exports them in full 64 bit.
>>> 
>>> References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/0215.html
>>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>>> 
>> 
>> What is the point since net_device_stats has only 32 bit counters.
>> The last time this came up the issue was is that is not possible
>> to atomically increment a 64 bit counter on most 32 bit platforms.
>
>On 64-bit it has 64-bit counters, yet we only report 32-bit
>counters to userspace via netlink even in that case.
>
>That's what Jan is fixing here.

On a side note, is it perhaps possible to use jiffies-like magic to
also have 64-bit counters on 32-bit, or is that still too expensive?
