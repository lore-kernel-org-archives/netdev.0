From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC PATCH v1 1/2] lsm: Add hooks to the TUN driver
Date: Thu, 6 Aug 2009 10:52:58 -0500
Message-ID: <20090806155257.GA32427@us.ibm.com>
References: <20090804211304.10798.65601.stgit@flek.lan> <200908051758.39051.paul.moore@hp.com> <20090806021558.GA17998@us.ibm.com> <200908061024.54786.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eparis@redhat.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200908061024.54786.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Paul Moore (paul.moore@hp.com):
> On Wednesday 05 August 2009 10:15:58 pm Serge E. Hallyn wrote:
> > Quoting Paul Moore (paul.moore@hp.com):
> > > On Wednesday 05 August 2009 10:13:50 am Serge E. Hallyn wrote:
> > > > Quoting Paul Moore (paul.moore@hp.com):
> > >
> > > [NOTE: my email has been out all day due to some mysterious FS issue so
> > > my apologies for not replying sooner]
> > >
> > > ...
> > >
> > > > The checks before and after this patch are not equivalent.  Post-patch,
> > > > one must always have CAP_NET_ADMIN to do the attach, whereas pre-patch
> > > > you only needed those if current_cred() did not own the tun device.  Is
> > > > that intentional?
> > >
> > > Nope, just a goof on my part; I misread the booleans and haven't fully
> > > tested the patch yet so it slipped out, thanks for catching it.  This
> > > brings up a good point, would we rather move the TUN owner/group checks
> > > into the cap_tun_* functions or move the capable() call back into the TUN
> > > driver?  The answer wasn't clear to me when I was looking at the code
> > > before and the uniqueness of the TUN driver doesn't help much in this
> > > regard.
> >
> > I see the question being asked as:  Does this device belong to
> > the caller and, if not, is the caller privileged to act
> > anyway?'  So I think the capable call should be moved back
> > into the tun driver, followed by a separate security_tun_dev_attach()
> > check, since that is a separate, restrictive question.
> 
> Works for me, I'll make the change.
> 
> BTW, the main reason for posting the patches in such an early state was to 
> solicit feedback on the location and types of hooks added; I've read lots of 
> good feedback but nothing regarding the fundamental aspects of the hooks ... 
> any comments before I push out v2?

Oh now that you mention it, yes - I think the security_tun_dev_attach()
should be called again separately after the post_create() hook.

As for more general comments on whether or which tuntap-specific hooks
need to exist, two things.  First, if you have specific requirements
in mind please do share those, otherwise I'm working based on what I
see in Documentation/networking/tuntap.txt and drivers/net/tun.c.  Second,
based on my understanding i think the hooks you have make sense,
but is there any way to relabel a tun socket?  Since they are always
labeled with current_sid(), that seems restrictive...  I see that you
don't want to use sockcreate_sid, but (to use a made-up example not
reflecting reality) a kvm_setup_t task couldn't create a tun sock for
a kvm_run_t task to use, right?

-serge
