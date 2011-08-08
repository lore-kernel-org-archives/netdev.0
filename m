From: Tejun Heo <tj@kernel.org>
Subject: Re: [EXAMPLE CODE] Parasite thread injection and TCP connection
 hijacking
Date: Mon, 8 Aug 2011 12:20:45 +0200
Message-ID: <20110808102045.GJ23937@htj.dyndns.org>
References: <20110806121247.GC23937@htj.dyndns.org>
 <4E3D3768.3070108@mit.edu>
 <20110806130037.GD23937@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Nathan Lynch <ntl@pobox.com>,
	Oren Laadan <orenl@cs.columbia.edu>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Lutomirski <luto@MIT.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:48350 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab1HHKUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 06:20:50 -0400
Content-Disposition: inline
In-Reply-To: <20110806130037.GD23937@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 06, 2011 at 03:00:37PM +0200, Tejun Heo wrote:
> Hello,
> 
> On Sat, Aug 06, 2011 at 08:45:28AM -0400, Andy Lutomirski wrote:
> > > 2. Decide where to inject the foreign code and save the original code
> > >    with PTRACE_PEEKDATA.  Tracer can poke any mapped area regardless
> > >    of protection flags but it can't add execution permission to the
> > >    code, so it needs to choose memory area which already has X flag
> > >    set.  The example code uses the page the %rip is in.
> > 
> > If the process is executing from the vsyscall page, then you'll
> > probably fail.  (Admittedly, this is rather unlikely, given that the
> > vsyscalls are now exactly one instruction.)  Presumably you also
> > fail if executing from a read-only MAP_SHARED mapping.
> 
> Heh, yeah, I originally thought about scanning /proc/PID/maps to look
> for the page to use but was lazy and just used %rip.  I think that
> should work.  I'll note the problem in README.

Okay, updated README.

  http://code.google.com/p/ptrace-parasite/source/browse/README

Thanks.

-- 
tejun
