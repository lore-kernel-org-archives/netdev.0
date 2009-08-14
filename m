From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: fixed drivers that support netpoll use
 ndo_start_xmit()
Date: Fri, 14 Aug 2009 16:32:32 -0700 (PDT)
Message-ID: <20090814.163232.234331420.davem@davemloft.net>
References: <1250226751.29401.82.camel@dengdd-desktop>
	<1250264019.3807.1301.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dongdong.deng@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruce.Ashfield@windriver.com,
	jason.wessel@windriver.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751640AbZHNXcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:32:21 -0400
In-Reply-To: <1250264019.3807.1301.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Fri, 14 Aug 2009 10:33:39 -0500

> On Fri, 2009-08-14 at 13:12 +0800, DDD wrote:
>> The NETPOLL API requires that interrupts remain disabled in
>> netpoll_send_skb(). The use of spin_lock_irq() and spin_unlock_irq()
>> in the NETPOLL API callbacks causes the interrupts to get enabled and
>> can lead to kernel instability.
>> 
>> The solution is to use spin_lock_irqsave() and spin_unlock_restore()
>> to prevent the irqs from getting enabled while in netpoll_send_skb().
 ...
>> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
>> Signed-off-by: Jason Wessel <jason.wessel@windriver.com>
>> Acked-by: Bruce Ashfield <bruce.ashfield@windriver.com>
> 
> Acked-by: Matt Mackall <mpm@selenic.com>

Applied, thanks everyone.

> Perhaps we should also have a WARN_ONCE if start_xmit returns with
> interrupts enabled?

Probably a good idea.
