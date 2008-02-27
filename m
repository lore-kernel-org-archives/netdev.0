From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: lockdep trace from rc2.
Date: Tue, 26 Feb 2008 19:54:00 -0800
Message-ID: <20080226195400.3f6e010b@extreme>
References: <20080225022237.GA3907@codemonkey.org.uk>
	<20080226.181354.33497295.davem@davemloft.net>
	<20080226195157.46645a62@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbYB0DyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 22:54:07 -0500
In-Reply-To: <20080226195157.46645a62@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Feb 2008 19:51:57 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Tue, 26 Feb 2008 18:13:54 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Dave Jones <davej@codemonkey.org.uk>
> > Date: Sun, 24 Feb 2008 21:22:37 -0500
> > 
> > > https://bugzilla.redhat.com/show_bug.cgi?id=431038 has some more info,
> > > but the trace is below...
> > > I'll get an rc3 kernel built and ask the user to retest, but in case this
> > > isn't a known problem, I'm forwarding this here.
> > 
> > So basically, tulip's ->stop() calls tulip_down() which does a
> > flush_scheduled_work().
> > 
> > Lockdep is saying that the RTNL mutex (which is held when we
> > call the driver's ->stop() method) conflicts with that work
> > queue lock that flush_scheduled_work() takes.
> > 
> > Maybe this has something to do with how linkwatch works, but
> > I can't say that I've seen this before nor do I quite understand
> > what lockdep doesn't exactly like here.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> This has come up before in other drivers,
> you can't call flush_scheduled_work under RTNL.

Correct link: http://kerneltrap.org/mailarchive/linux-kernel/2007/4/11/76312
