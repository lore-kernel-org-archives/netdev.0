From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: sch_generic warn_on (timed out)
Date: Wed, 20 Jul 2011 09:38:32 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1107200931080.1084@JBRANDEB-DESK2.amr.corp.intel.com>
References: <20110711204834.GA4950@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40460 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698Ab1GTQid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 12:38:33 -0400
In-Reply-To: <20110711204834.GA4950@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 11 Jul 2011, Dave Jones wrote:
>             WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
>                       dev->name, netdev_drivername(dev, drivername, 64), i);
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=702723 is our 'master bug' that we're
> duping all others against. It seems to be showing up on a variety of different
> hardware (r8169, atl1c, ipheth, e1000e, 8139too). Do all these drivers need
> fixing ? or is it just 'crap hardware' ?

neither, probably
 
> note that I've only been looking through fedora 15 bugs so far (which is still on 2.6.38),
> but looking at the commit log for sch_generic, it doesn't seem that there's anything
> obvious that needs backporting.

it used to just be a KERN_ERR printk, then it changed it to be a WARN_ONCE 
in order to trigger kerneloops reports so we knew how many people were 
getting tx hangs from their hardware.

The bad news is there is never anything useful in the backtrace, besides 
what driver it is.  Users have been trained to send backtrace for panic 
messages, and in this case it doesn't help very much to identify what 
the problem was.

If the reports within each driver were able to be traced back to a 
specific *model* of hardware then that might be useful (particularly for 
Intel hardware).  Maybe the WARN_ONCE should print vendor/device pair so 
we would at least know the hardware from the panic trace.

If this is happening more frequently on F15 than F14 across multiple 
pieces of hardware, it may indicate that a kernel/stack change is starting 
to (ab)use a changed working model that is causing an issue, or that there 
is an actual kernel issue with locks or interrupts or tx completions that 
is causing an excessive delay in completion of transmits.

Dave can you query for F14 reports and/or isolate what kernel this started 
with?
