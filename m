From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 5/9] netconsole: Introduce dev_status member
Date: Thu, 5 Jul 2007 15:06:01 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707051501190.15925@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070705063904.GG17650@tasint.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:51067 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757868AbXGEJOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 05:14:31 -0400
In-Reply-To: <20070705063904.GG17650@tasint.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jul 2007, Joel Becker wrote:
> On Wed, Jul 04, 2007 at 04:38:04PM +0530, Satyam Sharma wrote:
> > -	if (!(event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
> > -		goto done;
> > +	if (!(event == NETDEV_UP || event == NETDEV_DOWN ||
> > +	      event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
> > +	      	goto done;
> >
> >  	if (nt->np.dev == dev) {
> >  		switch (event) {
> 
> 	It's a small nit, but isn't the large if() just the degenerate
> default case of the switch()?  Why have it at all?  

Yes, the large if() is redundant in this particular patch.

But in further patches, the switch() is enclosed inside a 
spin_lock_irqsave() and list_for_each_entry(target_list) and so the
large if() upfront saves us from unnecessarily disabling interrupts
and iterating through the entire target_list in the case that it is
a notification for an event that we don't care about.

So I'll remove this if() from this patch and introduce it in the
later one itself, which is where it starts making some sense, anyway.

Satyam
