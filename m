From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 15:20:08 -0500
Message-ID: <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
 <51CC996F.3020507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:34884 "EHLO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752933Ab3F0UUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 16:20:18 -0400
Received: by mail-vb0-f51.google.com with SMTP id x17so1079203vbf.10
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 13:20:12 -0700 (PDT)
In-Reply-To: <51CC996F.3020507@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 12:58:39PM -0700, Rick Jones wrote:
> On 06/27/2013 12:22 PM, Shawn Bohrer wrote:
> >I'm looking for opportunities to improve the multicast receive
> >performance for our application, and I thought I'd spend some time
> >trying to understand what I thought might be a small/simple
> >improvement.  Profiling with perf I see that there is spin_lock
> >contention in __udp4_lib_mcast_deliver:
> >
> >0.68%  swapper  [kernel.kallsyms]               [k] _raw_spin_lock
> >        |
> >        --- _raw_spin_lock
> >           |
> >           |--24.13%-- perf_adjust_freq_unthr_context.part.21
> >           |
> >           |--22.40%-- scheduler_tick
> >           |
> >           |--14.96%-- __udp4_lib_mcast_deliver
> 
> Are there other processes showing _raw_spin_lock time?  It may be
> more clear to add a --sort symbol,dso or some such to your perf
> report command.  Because what you show there suggests less than 1%
> of the active cycles are in _raw_spin_lock.

You think I'm wasting time going after small potatoes huh?  On a
normal system it looks like it is about .12% total which is indeed
small but my thinking was that I should be able to make that go to 0
easily by ensuring we use unique ports and only have one socket per
multicast addr:port.  Now that I've failed at making it go to 0 I
would mostly like to understand what part of my thinking was flawed.
Or perhaps I can make it go to zero if I do ...

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
