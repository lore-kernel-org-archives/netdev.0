From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Thu, 9 Dec 2010 11:16:11 -0800
Message-ID: <20101209111611.1d2e6e2b@nehalam>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
	<4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org>
	<4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org>
	<20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org>
	<m1ipz3d46m.fsf@fess.ebiederm.org>
	<m1mxofa8dg.fsf_-_@fess.ebiederm.org>
	<4D00F58A.2050307@hp.com>
	<m139q6ahld.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, stable@kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41003 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166Ab0LITQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 14:16:18 -0500
In-Reply-To: <m139q6ahld.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Dec 2010 11:09:34 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Brian Haley <brian.haley@hp.com> writes:
> 
> > On 12/08/2010 11:16 PM, Eric W. Biederman wrote:
> >> Finding the real bug is beyond me right now, but fixing the regression
> >> in disable_ipv6 is simple.  We can just delete ::1 when we bring down
> >> the loopback interface, and it will be restored automatically when we
> >> bring the loopback interface back up.
> >
> > Hi Eric,
> >
> > This would work as well, same check, different way.
> 
> But that looks like less of an obvious magic exception.  The only
> address it is safe to ignore on is ::1, because we always restore it
> when we bring the loopback interface up.
> 
> Long term we really do want to keep the loopback address.  But
> that actually requires finding and fixing what is broken in
> ipv6.
> 
> So let's please keep this a line that we can easily remove.  It isn't
> like interfaces coming up and down are a fast path where every cycle
> counts.  We just need to be reasonably efficient.

No but since removing address propagates up to user space daemons
like Quagga please analyze and fix the problem, don't just look
for band aid.
