From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/14] netlink: implement memory mapped sendmsg()
Date: Fri, 19 Apr 2013 13:04:38 +0200
Message-ID: <20130419110438.GD19523@macbook.localnet>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
 <1366217229-22705-9-git-send-email-kaber@trash.net>
 <1366239463.2752.3.camel@bwh-desktop.uk.solarflarecom.com>
 <20130418103125.GB25166@macbook.localnet>
 <1366302386.2735.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366302386.2735.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 05:26:26PM +0100, Ben Hutchings wrote:
> On Thu, 2013-04-18 at 12:31 +0200, Patrick McHardy wrote:
> > On Wed, Apr 17, 2013 at 11:57:43PM +0100, Ben Hutchings wrote:
> > > On Wed, 2013-04-17 at 18:47 +0200, Patrick McHardy wrote:
> > > > Add support for mmap'ed sendmsg() to netlink. Since the kernel validates
> > > > received messages before processing them, the code makes sure userspace
> > > > can't modify the message contents after invoking sendmsg(). To do that
> > > > only a single mapping of the TX ring is allowed to exist and the socket
> > > > must not be shared. If either of these two conditions does not hold, it
> > > > falls back to copying.
> > > [...]
> > > 
> > > Is this resistant against copy_to_process()?
> > 
> > I don't know, there's no copy_to_process() function is the tree I'm using.
> 
> Sorry, I mean process_vm_writev().  copy_to_process() was the name in an
> earlier version of CMA.

I'm not sure whether process_vm_writev() allows to write to a memory mapped
area and, if so, whether it would invoke vm_ops->open() before doing so.

I'm looking into that, thanks.
