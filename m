From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Fri, 16 Mar 2012 17:04:13 -0500
Message-ID: <20120316220413.GA31359@burratino>
References: <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
 <1327811546.5400.291.camel@deadeye>
 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327932311.5400.429.camel@deadeye>
 <1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327934477.5400.448.camel@deadeye>
 <1327935455.2297.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327936900.2297.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <SNT141-W2773C07AA4E8276F3E1E4496730@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, ben@decadent.org.uk, kirjanov@gmail.com,
	netdev@vger.kernel.org, benoit.mortier@opensides.be,
	herbert@gondor.apana.org.au
To: "Mike ." <mike-bugreport@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44451 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031333Ab2CPWEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 18:04:31 -0400
Received: by iagz16 with SMTP id z16so5992145iag.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 15:04:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <SNT141-W2773C07AA4E8276F3E1E4496730@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

Mike . wrote:

>> Oh well, we also must make sure we held np->lock in TX completion when
>> doing our test to eventually call netif_wake_queue(), I missed it was
>> released too early.
>>
>> here is a more complete patch.
>
> I applied the patch, recompiled the module, loaded it into the kernel and
> started testing traffic on the interface with the following result :
>
> [ 1124.008030] ------------[ cut here ]------------
> [ 1124.008101] WARNING: at /build/buildd-linux-2.6_3.2.1-2-i386-4wAPNj/linux-2.6-3.2.1/debian/build/source_i386_none/net/sched/sch_generic.c:255 dev_watchdog+0xb1/0x104()
> [ 1124.008201] Hardware name:
> [ 1124.008252] NETDEV WATCHDOG: eth1 (sundance): transmit queue 0 timed out
[...]
> After this the same repeat of transmit timeouts (as posted earlier) in the
> log untill I down the interface.

Thanks.  I assume current 3.3 release candidates behave the same way.

Based on [2], it looks like v2.6.25-rc9~99^2~24 ([NET]: Add preemption
point in qdisc_run, 2008-03-28) made this easier to trip.

As for the next step: I'd suggest posting a summary of the symptoms,
which kernel versions you have tested, and a link to [1] at
http://bugzilla.kernel.org/, product Drivers, component Network, and
letting us know the bug number so we can track it without forgetting
what has already been learned.

Hope that helps,
Jonathan

[1] http://thread.gmane.org/gmane.linux.network/219101
