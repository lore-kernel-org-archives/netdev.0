From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to
 tasklet_hrtimer
Date: Sat, 22 Aug 2009 17:54:23 -0700 (PDT)
Message-ID: <20090822.175423.164703934.davem@davemloft.net>
References: <20090821.170330.217935645.davem@davemloft.net>
	<4A8FDECF.3040601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933404AbZHWAyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 20:54:11 -0400
In-Reply-To: <4A8FDECF.3040601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 22 Aug 2009 14:04:31 +0200

> David Miller wrote, On 08/22/2009 02:03 AM:
> 
>> None of this stuff should execute in hw IRQ context, therefore
>> use a tasklet_hrtimer so that it runs in softirq context.
> 
> Do you mean __netif_schedule()?

No, that works fine from HW irq context.

> Could you explain it more?

It's that throttled flag bit setting.  It's still unsafe but at least
we're in a position now to use softirq locking or atomic bitops to
maintain it properly.
