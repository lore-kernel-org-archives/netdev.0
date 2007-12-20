From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 21:04:12 +0100
Message-ID: <476ACABC.4010503@linux.intel.com>
References: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>	 <20071220091603.0d69b045@deepthought>	 <823114761-1198171803-cardhu_decombobulator_blackberry.rim.net-937108990-@bxe019.bisx.prod.on.blackberry>	 <20071220095121.7859c023@deepthought> <476ABDDF.8080607@intel.com>	 <476ABE7D.60901@linux.intel.com> <476AC105.9090206@intel.com> <82e4877d0712201200h7b994175u841d1efa047cefff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Parag Warudkar <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:47276 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759798AbXLTUMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 15:12:44 -0500
In-Reply-To: <82e4877d0712201200h7b994175u841d1efa047cefff@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parag Warudkar wrote:
> On Dec 20, 2007 2:22 PM, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> ok, that's just bad and if there's no user-defineable limit to the deferral I
>> definately don't like this change.
>>
>> Can I safely assume that any irq will cause all deferred timers to run?
> 
> I think even other causes for wakeup like process related ones will
> cause the CPU to go busy and run the timers.
> This, coupled with the fact that no one is yet able to reach 0 wakeups
> per second makes it pretty unlikely that deferrable timers will be
> deferred indefinitely.

0.8 is easy on single core today.
multicore just increases how idle you can be for a given core.

> 
>> If this is the case then for e1000 this patch is still OK since the watchdog needs
>> to run (1) after a link up/down interrupt or (2) to update statistics. Those
>> statistics won't increase if there is no traffic of course...
>>
> 
> I think it is reasonable for Network driver watchdogs to use a
> deferrable timer - if the machine is 100% IDLE there is no one needing
> the network to be up. If there is something running even on the other
> CPU - that is going to cause an IPI, reschedule, TLB invalidation etc.
> which will make it very likely in practice that each CPU will be
> interrupted in reasonable amount of time.

this is not correct; many machines are idle waiting for network data. Think of webservers...

> 
> Of course there are theoretical cases where we could land into a
> situation where a CPU in a multiprocessor machine is IDLE infinitely
> and that causes the watchdog that happens to be bound to run on the
> same CPU to not run. To take care of these unlikely cases I think the
> timer mechanism should have a reasonable limit on how long a CPU can
> go IDLE if there are deferrable timers.

how about something else instead: a timer mechanism that takes a range instead..
that at least has defined semantics; the deferrable semantics really are "indefinite".
Lets keep at least the semantics clear and clean.

