From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 15:47:12 +0000
Message-ID: <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <50F2FF1B.3020708@mageia.org> <50F313A5.3020707@mageia.org>
	   <50F49B7E.50906@redhat.com> <50F52956.50201@mageia.org>
	  <1358244688.4264.7.camel@cr0> <50F53596.4070200@mageia.org>
	 <1358316366.14898.8.camel@cr0> <50F6B761.8070106@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, Thomas Backlund <tmb@mageia.org>,
	Eric Blake <eblake@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <libvirt-list@redhat.com>,
	<tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	<libc-alpha@sourceware.org>, <schwab@suse.de>,
	<carlos@systemhalted.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50F6B761.8070106@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-16 at 23:21 +0900, YOSHIFUJI Hideaki wrote:
> Cong Wang wrote:
> > (Cc'ing some glibc developers...)
> > 
> > Hello,
> > 
> > In glibc source file inet/netinet/in.h and kernel source file
> > include/uapi/linux/in6.h, both define struct in6_addr, and both are
> > visible to user applications. Thomas reported a conflict below.
> > 
> > So, how can we handle this? /me is wondering why we didn't see this
> > before.
[...]
> This is not a new issue.  In addition to this,
> netinet/in.h also conflits with linux/in.h.
> 
> We might have
>  #if !defined(__GLIBC__) || !defined(_NETINET_IN_H)
>  :
>  #endif
> around those conflicting definitions in uapi/linux/in{,6}.h.

This only solves half the problem, as <netinet/in.h> might be included
after <linux/in.h>.  Also, not all Linux userland uses glibc.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
