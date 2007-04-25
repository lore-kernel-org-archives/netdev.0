From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 15:53:19 -0400
Message-ID: <20070425195319.GA25080@hmsreliant.homelinux.net>
References: <20070425122924.88391585.akpm@linux-foundation.org> <m1ps5sqlv4.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3244 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683AbXDYTxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 15:53:50 -0400
Content-Disposition: inline
In-Reply-To: <m1ps5sqlv4.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 01:45:19PM -0600, Eric W. Biederman wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > I note that the networking tree is adding new sysctls:
> >
> > <<<<<<< HEAD/include/linux/sysctl.h
> >         NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> > =======
> >         NET_IPV6_OPTIMISTIC_DAD=24,
> >         NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> >>>>>>>> /include/linux/sysctl.h
> >
> > (Well, it's trying to - there are some git rejects in net-2.6.22)
> >
> > But we kind-of decided a while back to stop doing that and to
> > use CTL_UNNUMBERED.
> >
> > Frankly, I don't 100% remember the thinking - Eric, can you please remind
> > us?
> 
> The thinking is this:
> 
>   Binary sysctl numbers are a problem because of patch conflicts like
>   the above, and the related user space breakage they cause.
> 
>   In practice no one uses binary sysctl numbers.
> 
> So the policy should be to add new sysctl's using CTL_UNNUMBERED
> (to prevent patch conflicts and user space breakage).
> 
> There may be cases where someone actually needs the binary sysctl
> interface.  Once there is a demonstrated need we can go back
> and very carefully add numbers for these very few cases, with
> a strong review process.
> 
> Adding binary sysctl numbers should be done as carefully as and with
> as much review as adding syscall numbers, and distro kernels and other
> stable kernels should never get a sysctl number backport until the
> number first reaches Linus's tree.  To avoid difference in meaning
> between different kernels.
> 
> Given that no one except on BSD uses the binary sysctl interface
> anyway my personal preference is to just freeze it and to reduce the
> number of binary sysctls we support if possible.
> 
> Eric
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I did the optimistic dad sysctl, and have no strict use for numbered sysctls (I
was just unaware of the policy).  I'll work up a patch to use
register_sysclt_table with CTL_UNNUMBERED in the next few days.

Regards
Neil

