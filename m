From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] crash in 2.6.22-git2 sysctl_set_parent()
Date: Mon, 16 Jul 2007 12:22:36 -0500
Message-ID: <20070716172236.GA5771@austin.ibm.com>
References: <20070713200515.GS5549@austin.ibm.com> <m13azreqtr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:52374 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582AbXGPRWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 13:22:38 -0400
Content-Disposition: inline
In-Reply-To: <m13azreqtr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 07:06:56PM -0600, Eric W. Biederman wrote:
> >  			.data		= &ipv4_devconf.loop,
> >  			.maxlen		= sizeof(int),
> >  			.mode		= 0644,
> > +			.child	= 0x0,
> >  			.proc_handler	= &proc_dointvec,
> >  		},
> Where did this entry above in devinet_sysctl come from?

My bad.
I habitually apply the "send-to-self" patch, since some of the 
network testing that I do is easiest if I load up the all of the 
adapters in the same box. (If you're not familiar with this patch ... 
its great, and I wish it was integratedd into mainline. It allows
one to drive network traffic through the physical devices, even
if they are in the same box.  Without it, the network stack is
too clever, and won't allow you to do this.)

> > +		{
> > +			.ctl_name	= 0,
> > +			.procname	= 0,
> > +		},
> I probably would have just done:
> +		{},

Yes, in retrospect, this would have been the simplest solution.

> What added the additional entry to devinet_root_dir?  I don't see that
> in Linus' tree?
> 
> The result may be fine but if it isn't named in a per network device
> manner we are adding duplicate entries to the root /proc/sys directory
> which is wrong.
> 
> Actually come to think of it I am concerned that someone added a
> settable entry into /proc/sys/ it should at least be in /proc/sys/net/
> where it won't conflict with other uses of that directory.  Especially
> as things like network devices have user controlled names.

Sigh. Silly me. Haste makes waste.

--linas

