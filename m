From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Thu, 15 Nov 2007 02:38:32 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0711150225280.3658@u.domain.uli>
References: <200711131129.58868.borntraeger@de.ibm.com>
 <20071113.024500.155458534.davem@davemloft.net> <20071114021131.GB2523@verge.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, borntraeger@de.ibm.com,
	netdev@vger.kernel.org, ebiederm@xmission.com, wensong@linux-vs.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:1777 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754773AbXKOAiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 19:38:51 -0500
In-Reply-To: <20071114021131.GB2523@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 13 Nov 2007, Simon Horman wrote:

> > > Running the latest git code I get the following messages during boot:
> > > sysctl table check failed: /net/ipv4/vs/drop_entry .3.5.21.4 Missing strategy
> > > [...]		  
> > > sysctl table check failed: /net/ipv4/vs/drop_packet .3.5.21.5 Missing strategy
> > > [...]
> > > sysctl table check failed: /net/ipv4/vs/secure_tcp .3.5.21.6 Missing strategy
> > > [...]
> > > sysctl table check failed: /net/ipv4/vs/sync_threshold .3.5.21.24 Missing strategy
> > > 
> > > I removed the binary sysctl handler for those messages and also removed
> > > the definitions in ip_vs.h. The alternative would be to implement a 
> > > proper strategy handler, but syscall sysctl is deprecated.
> > > 
> > > There are other sysctl definitions that are commented out or work with 
> > > the default sysctl_data strategy. I did not touch these. 
> > > 
> Hi Christian, Hi Dave,
> 
> I have indeed been looking into this of late. Assuming that you use of
> CTL_UNNUMBERED is correct, this patch looks fine to me.  Acked.
> 
> I was planning to do the same and also switch over all the other entries
> over to use CTL_UNNUMBERED, as its hard to imagine that anyone is using
> the sys_sysctl interface to IPVS.
> 
> As for the commented out entries. They are supposed to be exposed by
> some other means - I believe the thinking was to comply with the don't
> expose stuff in proc any more idea. Where is the best place to expose
> this kind of stuff?

	I assume /proc/sys is still valid place, only sysctl interface
is scheduled for removal. So, as long as these entries are not
accessible from sysctl it is safe to run without strategy handler but if
values can be changed then we will need strategy handler to
properly call update_defense_level() as done in proc_do_defense_mode()
as proc_handler. There could be side effects if new mode is not applied.

Regards

--
Julian Anastasov <ja@ssi.bg>
