From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 08/14] netlink: implement memory mapped sendmsg()
Date: Thu, 18 Apr 2013 17:26:26 +0100
Message-ID: <1366302386.2735.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
	 <1366217229-22705-9-git-send-email-kaber@trash.net>
	 <1366239463.2752.3.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130418103125.GB25166@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130418103125.GB25166@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-18 at 12:31 +0200, Patrick McHardy wrote:
> On Wed, Apr 17, 2013 at 11:57:43PM +0100, Ben Hutchings wrote:
> > On Wed, 2013-04-17 at 18:47 +0200, Patrick McHardy wrote:
> > > Add support for mmap'ed sendmsg() to netlink. Since the kernel validates
> > > received messages before processing them, the code makes sure userspace
> > > can't modify the message contents after invoking sendmsg(). To do that
> > > only a single mapping of the TX ring is allowed to exist and the socket
> > > must not be shared. If either of these two conditions does not hold, it
> > > falls back to copying.
> > [...]
> > 
> > Is this resistant against copy_to_process()?
> 
> I don't know, there's no copy_to_process() function is the tree I'm using.

Sorry, I mean process_vm_writev().  copy_to_process() was the name in an
earlier version of CMA.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

