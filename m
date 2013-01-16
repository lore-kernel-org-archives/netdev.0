From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 17:10:11 +0000
Message-ID: <1358356211.2923.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <50F2FF1B.3020708@mageia.org> <50F6B761.8070106@linux-ipv6.org>
	 <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
	 <201301161205.04502.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <libc-alpha@sourceware.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Cong Wang <amwang@redhat.com>,
	Thomas Backlund <tmb@mageia.org>,
	Eric Blake <eblake@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <libvirt-list@redhat.com>,
	<tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	<schwab@suse.de>, <carlos@systemhalted.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201301161205.04502.vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-16 at 12:04 -0500, Mike Frysinger wrote:
> On Wednesday 16 January 2013 10:47:12 Ben Hutchings wrote:
> > On Wed, 2013-01-16 at 23:21 +0900, YOSHIFUJI Hideaki wrote:
> > > Cong Wang wrote:
> > > > (Cc'ing some glibc developers...)
> > > > 
> > > > Hello,
> > > > 
> > > > In glibc source file inet/netinet/in.h and kernel source file
> > > > include/uapi/linux/in6.h, both define struct in6_addr, and both are
> > > > visible to user applications. Thomas reported a conflict below.
> > > > 
> > > > So, how can we handle this? /me is wondering why we didn't see this
> > > > before.
> > 
> > [...]
> > 
> > > This is not a new issue.  In addition to this,
> > > netinet/in.h also conflits with linux/in.h.
> > > 
> > > We might have
> > > 
> > >  #if !defined(__GLIBC__) || !defined(_NETINET_IN_H)
> > >  
> > >  #endif
> > > 
> > > around those conflicting definitions in uapi/linux/in{,6}.h.
> > 
> > This only solves half the problem, as <netinet/in.h> might be included
> > after <linux/in.h>.  Also, not all Linux userland uses glibc.
> 
> certainly true, but the current expectation is that you don't mix your ABIs.

Whose expectation?  Which ABIs are being mixed?

> if you're programming with the C library API, then use the C library headers.  
> if you're banging directly on the kernel, then use the kernel headers.  not 
> saying it's a perfect solution, but it works for the vast majority of use 
> cases.

In practice most C programs for Linux will use a mixture of thinly
wrapped system calls and higher-level APIs from the C library, and never
really call the kernel directly (as that requires inline assembler).
Userland programmers will work around this historical mess by tweaking
the #include order or splitting source files.  But they shouldn't have
to.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
