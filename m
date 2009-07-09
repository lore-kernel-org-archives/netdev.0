From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Thu, 9 Jul 2009 15:25:56 +0100
Message-ID: <a5d9929e0907090725h44fe8ccdm100ee4b67407bda8@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local>
	<200907090023.18040.andres@anarazel.de> <20090708224828.GD3666@ami.dom.local>
	<alpine.LFD.2.00.0907090956490.24704@localhost.localdomain>
	<20090709104412.GA3651@ami.dom.local> <alpine.LFD.2.00.0907091401040.24704@localhost.localdomain>
	<20090709132256.GB3651@ami.dom.local> <alpine.LFD.2.00.0907091601120.24704@localhost.localdomain>
	<20090709142414.GC3651@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:32898 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759419AbZGIO0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 10:26:19 -0400
In-Reply-To: <20090709142414.GC3651@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 9, 2009 at 3:24 PM, Jarek Poplawski<jarkao2@gmail.com> wrote:
> On Thu, Jul 09, 2009 at 04:15:28PM +0200, Thomas Gleixner wrote:
>> On Thu, 9 Jul 2009, Jarek Poplawski wrote:
>> > On Thu, Jul 09, 2009 at 02:03:50PM +0200, Thomas Gleixner wrote:
>> > > On Thu, 9 Jul 2009, Jarek Poplawski wrote:
>> > > > >
>> > > > > I have the feeling that the code relies on some implicit cpu
>> > > > > boundness, which is not longer guaranteed with the timer migration
>> > > > > changes, but that's a question for the network experts.
>> > > >
>> > > > As a matter of fact, I've just looked at this __netif_schedule(),
>> > > > which really is cpu bound, so you might be 100% right.
>> > >
>> > > So the watchdog is the one which causes the trouble. The patch below
>> > > should fix this.
>> >
>> > I hope so. On the other hand it seems it should work with this
>> > migration yet, so it probably needs additional debugging.
>>
>> Right. I just provided the patch to narrow down the problem, but
>> please test the fix of the hrtimer migration code which I sent out a
>> bit earlier: http://lkml.org/lkml/2009/7/9/150
>>
>> It fixes a possible endless loop in the timer code which is related to
>> the migration changes. Looking at the backtraces of the spinlock
>> lockup I think that is what you hit.
>
> Actually, Andres and Joao hit this, and I hope they'll try these two
> patches.
>
> Thanks,
> Jarek P.
>

I can only try later on today. Will post back as soon as i do it.

Joao Correia
