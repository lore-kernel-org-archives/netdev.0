From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Best way to set kernel thread affinity for handling a socket?
Date: Thu, 23 Aug 2012 18:51:14 +0100
Message-ID: <1345744274.2579.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAG4TOxNMRR_-bYJV1a_je2HKrpmVuGubH9ks4GdG8Shwa92K0w@mail.gmail.com>
	 <1345652493.2709.36.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAG4TOxOdTiahqVo6+cD=mCN5Ov_hLa_m5gBTuj5sUYsM+GgnYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22977 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751519Ab2HWRvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 13:51:20 -0400
In-Reply-To: <CAG4TOxOdTiahqVo6+cD=mCN5Ov_hLa_m5gBTuj5sUYsM+GgnYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 10:04 -0700, Roland Dreier wrote:
> On Wed, Aug 22, 2012 at 9:21 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > With RFS we try to do the reverse: move the packets to match the socket
> > user.   But it's not (yet) turned on by default.  See
> > Documentation/networking/scaling.txt
> 
> Fair enough.  However I think at least in this case it sounds like extra
> overhead: it should be easy for us to do everything on the CPU where
> the packets are being received.
> 
> >> I'm thinking about this in the context of the kernel's iSCSI target
> >> code (drivers/target/iscsi), which creates threads to handle each
> >> iSCSI connection and sets their CPU affinity pretty much randomly
> >> (well, based on some "thread id", cf iscsit_thread_get_cpumask()).
> >
> > Why set the affinity at all?
> 
> It's quite possible that, like a lot of other drivers/target code, this
> doesn't actually make any sense and the right answer is to rip it
> out completely.
> 
> Is the affinity due to waking up from a network receive event
> enough to keep the threads local to the right CPU?

I expect it to have some influence on where the receiving task is
scheduled, but it doesn't necessarily outweigh other factors that the
scheduler takes into account.  So you would really have to test this
yourself.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
