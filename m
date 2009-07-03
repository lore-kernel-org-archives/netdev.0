From: David Miller <davem@davemloft.net>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
 possibly?caused by netem)
Date: Fri, 03 Jul 2009 13:22:20 -0700 (PDT)
Message-ID: <20090703.132220.57384838.davem@davemloft.net>
References: <20090703061213.GA4847@ff.dom.local>
	<200907031326.21822.andres@anarazel.de>
	<20090703120301.GD4847@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andres@anarazel.de, arun@linux.vnet.ibm.com, tglx@linutronix.de,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756725AbZGCUWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 16:22:14 -0400
In-Reply-To: <20090703120301.GD4847@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 3 Jul 2009 12:03:01 +0000

> On Fri, Jul 03, 2009 at 01:26:21PM +0200, Andres Freund wrote:
>> On Friday 03 July 2009 08:12:13 Jarek Poplawski wrote:
>> > On Fri, Jul 03, 2009 at 03:31:31AM +0200, Andres Freund wrote:
>> > ...
>> >
>> > > Ok. I finally see the light. I bisected the issue down to
>> > > eea08f32adb3f97553d49a4f79a119833036000a :  timers: Logic to move non
>> > > pinned timers
>> > >
>> > > Disabling timer migration like provided in the earlier commit stops the
>> > > issue from occuring.
>> > >
>> > > That it is related to timers is sensible in the light of my findings,
>> > > that I could trigger the issue only when using delay in netem - that is
>> > > the codepath using qdisc_watchdog...
>> >
>> > Andres, thanks for your work and time. It saved me a lot of searching,
>> > because I wasn't able to trigger this on my old box.
>> Thanks. It allowed me to go through some of my remaining paperwork ;-)
>> 
>> Does anybody of you have an idea where the problem actually resides? 
> 
> Do you mean possibly broken timers are not enough?

Well, if you look at that commit the bisect pointed to Jarek, it is a
change which starts causing a situation which never happened before.
Namely, timers added on one cpu can be migrated and fire on another.

So this could be exposing races in the networking that technically
always existed.
