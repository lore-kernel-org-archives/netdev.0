From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: /proc/net/tcp rto,ato values not scaled properly
Date: Fri, 20 Jun 2008 12:31:12 -0700
Message-ID: <20080620123112.26202db9@extreme>
References: <20080620115603.5c494cab@extreme>
	<20080620.120526.246965779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41885 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbYFTTbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 15:31:18 -0400
In-Reply-To: <20080620.120526.246965779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008 12:05:26 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 20 Jun 2008 11:56:03 -0700
> 
> > I found another case where we are sending information to userspace
> > in the wrong HZ scale.  This should have been fixed back in 2.5 :-(
> > 
> > This means an ABI change but as it stands there is no way for an application
> > like ss to get the right value.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Agree with your patch, but 'ss' should be getting this kind of info
> from netlink not procfs, right?
> 

Yes, ss tries netlink first and fallsback to /proc.

I am in process of making sure all usages of HZ in iproute utilities
are correct.  The old user code assumed that the hz value used by tc (psched)
was also correct for lots of other places. That is where I keep finding
these turds.

Soon all uses of get_hz() in iproute will be replaced with 
either get_psched_hz() for tc; get_user_hz for clock
values, or just use ms or us.
