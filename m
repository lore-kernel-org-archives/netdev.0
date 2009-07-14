From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 09:00:55 -0700 (PDT)
Message-ID: <20090714.090055.56906831.davem@davemloft.net>
References: <20090709215606.526259917@linutronix.de>
	<20090712.135555.207096388.davem@davemloft.net>
	<alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, peterz@infradead.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54455
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751267AbZGNQAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 12:00:51 -0400
In-Reply-To: <alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 14 Jul 2009 10:55:14 +0200 (CEST)

> David,
> 
> On Sun, 12 Jul 2009, David Miller wrote:
> 
>> What should probably happen is that the hrtimer merely fires off work
>> at software interrupt context (perhaps a tasklet or similar), and that
>> software interrupt code take the qdisc's root lock throughout it's
>> execution.
> 
> Sigh, I almost expected that the removal of the callback modes will
> fire back some day.

Well this makes hrtimers decidedly less useful for networking and we
have a ton of bugs right now, basically in every hrtimer used by the
networking currently.

The only way we can use them, as things currently stand, is as
triggers for softirq work.

Is it really that troublesome to provide this kind of facility
generically, rather than having various subsystems replicate such code
where they want to use hrtimers and are restricted to softirqs?
