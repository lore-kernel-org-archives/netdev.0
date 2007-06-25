From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Mon, 25 Jun 2007 10:23:13 -0500
Message-ID: <20070625152313.GB19546@sergelap.austin.ibm.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com> <20070623.135737.22037347.davem@davemloft.net> <467D9B8F.2050403@garzik.org> <m1ejk28eku.fsf@ebiederm.dsl.xmission.com> <467DC8CC.3020002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, hadi@cyberus.ca,
	kaber@trash.net, Linus Torvalds <torvalds@linux-foundation.org>,
	containers@lists.osdl.org, greearb@candelatech.com,
	shemminger@linux-foundation.org, David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:42491 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756099AbXFYPXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 11:23:18 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5PEK3VE024806
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 10:20:03 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5PFNFfO484768
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 11:23:15 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5PFNErr021799
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 11:23:15 -0400
Content-Disposition: inline
In-Reply-To: <467DC8CC.3020002@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Jeff Garzik (jeff@garzik.org):
> Eric W. Biederman wrote:
> >Jeff Garzik <jeff@garzik.org> writes:
> >
> >>David Miller wrote:
> >>>I don't accept that we have to add another function argument
> >>>to a bunch of core routines just to support this crap,
> >>>especially since you give no way to turn it off and get
> >>>that function argument slot back.
> >>>
> >>>To be honest I think this form of virtualization is a complete
> >>>waste of time, even the openvz approach.
> >>>
> >>>We're protecting the kernel from itself, and that's an endless
> >>>uphill battle that you will never win.  Let's do this kind of
> >>>stuff properly with a real minimal hypervisor, hopefully with
> >>>appropriate hardware level support and good virtualized device
> >>>interfaces, instead of this namespace stuff.
> >>Strongly seconded.  This containerized virtualization approach just 
> >>bloats up
> >>the kernel for something that is inherently fragile and IMO less secure --
> >>protecting the kernel from itself.
> >>
> >>Plenty of other virt approaches don't stir the code like this, while
> >>simultaneously providing fewer, more-clean entry points for the 
> >>virtualization
> >>to occur.
> >
> >Wrong.  I really don't want to get into a my virtualization approach is 
> >better
> >then yours.  But this is flat out wrong.
> 
> >99% of the changes I'm talking about introducing are just:
> >- variable 
> >+ ptr->variable
> >
> >There are more pieces mostly with when we initialize those variables but
> >that is the essence of the change.
> 
> You completely dodged the main objection.  Which is OK if you are 
> selling something to marketing departments, but not OK
> 
> Containers introduce chroot-jail-like features that give one a false 
> sense of security, while still requiring one to "poke holes" in the 
> illusion to get hardware-specific tasks accomplished.
> 
> The capable/not-capable model (i.e. superuser / normal user) is _still_ 
> being secured locally, even after decades of work and whitepapers and 
> audits.
> 
> You are drinking Deep Kool-Aid if you think adding containers to the 
> myriad kernel subsystems does anything besides increasing fragility, and 
> decreasing security.  You are securing in-kernel subsystems against 
> other in-kernel subsystems.

No we're not.  As the name 'network namespaces' implies, we are
introducing namespaces for network-related variables.  That's it.

We are not trying to protect in-kernel subsystems from each other.  In
fact we're not even trying to protect userspace process from each other.
Though that will in part come free when user processes can't access each
other's data because they are in different namespaces.  But using an
LSM like selinux or a custom one to tag and enforce isolation would
still be encouraged.

> superuser/user model made that difficult 
> enough... now containers add exponential audit complexity to that.  Who 
> is to say that a local root does not also pierce the container model?

At the moment it does.

> >And as opposed to other virtualization approaches so far no one has been
> >able to measure the overhead.  I suspect there will be a few more cache
> >line misses somewhere but they haven't shown up yet.
> >
> >If the only use was strong isolation which Dave complains about I would
> >concur that the namespace approach is inappropriate.  However there are
> >a lot other uses.
> 
> Sure there are uses.  There are uses to putting the X server into the 
> kernel, too.  At some point complexity and featuritis has to take a back 
> seat to basic sanity.

Generally true, yes.

-serge
