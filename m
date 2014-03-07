From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt
 context.
Date: Fri, 07 Mar 2014 14:30:59 -0500 (EST)
Message-ID: <20140307.143059.2030830185766849286.davem@davemloft.net>
References: <87d2i17bq8.fsf@xmission.com>
	<20140304.192616.918758436987378525.davem@davemloft.net>
	<87ha7cwiry.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbaCGTbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 14:31:04 -0500
In-Reply-To: <87ha7cwiry.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Mar 2014 11:24:33 -0800

> Now that I have looked closer the printk generating a printk problem
> seems to be something that is best solved at the printk level.

I'm not so sure that disallowing printk recursion is necessary.

If you consider an error printk emitted from a device driver's
transmit function during netconsole output, netpoll handles this
transparently already.

Basically, what happens right now in this situation is that netpoll
queues it up when recursion is detected, and delayed work is scheduled
to process such pending packets.

The only issue at hand is the IRQ context bit.
