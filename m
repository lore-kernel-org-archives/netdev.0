From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 01 Sep 2009 15:51:45 -0700 (PDT)
Message-ID: <20090901.155145.97691775.davem@davemloft.net>
References: <200908311118.43024.denys@visp.net.lb>
	<20090831.013738.127727614.davem@davemloft.net>
	<20090831085848.GF5005@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755320AbZIAWva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 18:51:30 -0400
In-Reply-To: <20090831085848.GF5005@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 31 Aug 2009 08:58:49 +0000

> On Mon, Aug 31, 2009 at 01:37:38AM -0700, David Miller wrote:
>> From: Denys Fedoryschenko <denys@visp.net.lb>
>> Date: Mon, 31 Aug 2009 11:18:42 +0300
>> 
>> > 2.6.31-rc8 i got dmesg flooded. First message appearing even without patch, i 
>> > will make sure now what is a reason of that (i have HTB classes on ifb0, and 
>> > TBF on pppX).
>> > 
>> > [  155.199923] Attempt to kill tasklet from interrupt
>> 
>> We know the reasons for this message, it's an HTB regression and we're
>> working on it.
> 
> There is a few more than HTB. Btw, IMHO, we don't risk much (if at
> all) if we revert this qdisc_watchdog change. There is still CBQ
> problem, where we could probably reconsider Thomas Gleixner's first
> attempt with additional locking and irq disabling as a temporary
> solution?

As I stated in another email, I think my plan is going to be to
revert both tasklet_hrtimer changes and try to deal with this in
net-next-2.6 instead.
