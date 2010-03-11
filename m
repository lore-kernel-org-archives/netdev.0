From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 12:26:39 -0800 (PST)
Message-ID: <20100311.122639.258785986.davem@davemloft.net>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
	<1268337450-6749-4-git-send-email-jengelh@medozas.de>
	<20100311121239.14944fd5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758145Ab0CKU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 15:26:18 -0500
In-Reply-To: <20100311121239.14944fd5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 11 Mar 2010 12:12:39 -0800

> On Thu, 11 Mar 2010 20:57:29 +0100
> Jan Engelhardt <jengelh@medozas.de> wrote:
> 
>> `ip -s link` shows interface counters truncated to 32 bit. This is
>> because interface statistics are transported only in 32-bit quantity
>> to userspace. This commit adds a new IFLA_STATS64 attribute that
>> exports them in full 64 bit.
>> 
>> References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/0215.html
>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>> 
> 
> What is the point since net_device_stats has only 32 bit counters.
> The last time this came up the issue was is that is not possible
> to atomically increment a 64 bit counter on most 32 bit platforms.

On 64-bit it has 64-bit counters, yet we only report 32-bit
counters to userspace via netlink even in that case.

That's what Jan is fixing here.
