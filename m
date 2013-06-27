From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 16:54:11 -0500
Message-ID: <20130627215411.GC5936@sbohrermbp13-local.rgmadvisors.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
 <51CC996F.3020507@hp.com>
 <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com>
 <51CCA4C2.7050301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:57265 "EHLO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753249Ab3F0VyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 17:54:24 -0400
Received: by mail-ve0-f171.google.com with SMTP id b10so1238369vea.16
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 14:54:23 -0700 (PDT)
In-Reply-To: <51CCA4C2.7050301@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 01:46:58PM -0700, Rick Jones wrote:
> On 06/27/2013 01:20 PM, Shawn Bohrer wrote:
> >On Thu, Jun 27, 2013 at 12:58:39PM -0700, Rick Jones wrote:
> >>Are there other processes showing _raw_spin_lock time?  It may be
> >>more clear to add a --sort symbol,dso or some such to your perf
> >>report command.  Because what you show there suggests less than 1%
> >>of the active cycles are in _raw_spin_lock.
> >
> >You think I'm wasting time going after small potatoes huh?
> 
> Perhaps.  I also find it difficult to see the potatoes' (symbols')
> big picture in perf's default sorting :)
> 
> >On a normal system it looks like it is about .12% total which is
> >indeed small but my thinking was that I should be able to make that
> >go to 0 easily by ensuring we use unique ports and only have one
> >socket per multicast addr:port.  Now that I've failed at making it go
> >to 0 I would mostly like to understand what part of my thinking was
> >flawed. Or perhaps I can make it go to zero if I do ...
> 
> How do you know that time is actually contention and not simply
> acquire and release overhead?

Excellent point, and that could be the problem with my thinking.  I
just now tried (unsuccessfully) to use lockstat to see if there was
any contention reported.  I read Documentation/lockstat.txt and
followed the instructions but the lock in question did not appear to
be in the output.  I think I'm going to have to go with the assumption
that this is just acquire and release overhead.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
