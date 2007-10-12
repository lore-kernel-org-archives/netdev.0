From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-mm1
Date: Fri, 12 Oct 2007 00:13:25 -0700
Message-ID: <20071012001325.ba02a6f0.akpm@linux-foundation.org>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org>
	<20071012140328.f82af8e8.kamezawa.hiroyu@jp.fujitsu.com>
	<20071011234202.2f15bb76.akpm@linux-foundation.org>
	<20071012064658.GA8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	linux-kernel@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>,
	netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52936 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755700AbXJLHNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 03:13:44 -0400
In-Reply-To: <20071012064658.GA8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 07:46:58 +0100 Al Viro <viro@ftp.linux.org.uk> wrote:

> On Thu, Oct 11, 2007 at 11:42:02PM -0700, Andrew Morton wrote:
> > On Fri, 12 Oct 2007 14:03:28 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Thu, 11 Oct 2007 21:31:26 -0700
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > 
> > > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23/2.6.23-mm1/
> > > > 
> > > > - I've been largely avoiding applying anything since rc8-mm2 in an attempt
> > > >   to stabilise things for the 2.6.23 merge.
> > > > 
> > > On RHEL5/x86_64 environment,
> > > 
> > > ==
> > > [kamezawa@hannibal ref-2.6.23-mm1]$ make menuconfig
> > > Makefile:456: /home/kamezawa/ref-2.6.23-mm1/arch//Makefile: No such file or directory
> > > make: *** No rule to make target `/home/kamezawa/ref-2.6.23-mm1/arch//Makefile'.  Stop.
> > > ==
> > > 
> > > $(ARCH) cannot be detected automatically...
> > 
> > So you need to set $ARCH by hand?  I always do that so I didn't notice this.
> > 
> > > What information is useful for fixing this ?
> > 
> > Sam's email address ;)
> 
> More serious breakage happened to UML - include/asm-um/arch went straight
> to hell; I'll look into fixing that tomorrow...

I always forget to test uml.  But a quick test build seems to work until
it hits this:

arch/um/drivers/slip_kern.c: In function 'slip_init':
arch/um/drivers/slip_kern.c:34: error: 'struct net_device' has no member named 'header_cache_update'
arch/um/drivers/slip_kern.c:35: error: 'struct net_device' has no member named 'hard_header_cache'
arch/um/drivers/slip_kern.c:36: error: 'struct net_device' has no member named 'hard_header'

<looks at networking people>
