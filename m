From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Thu, 26 Feb 2009 12:24:50 -0800
Message-ID: <20090226122450.6d27eec6@nehalam>
References: <49A4D5D5.5090602@trash.net>
	<20090225061902.GA32430@gondor.apana.org.au>
	<49A4E3F8.4050406@trash.net>
	<49A4F0D7.20304@trash.net>
	<20090225084321.GA1101@gondor.apana.org.au>
	<m163ixk9t2.fsf@fess.ebiederm.org>
	<20090226062257.GA11511@gondor.apana.org.au>
	<m14oyhis31.fsf@fess.ebiederm.org>
	<20090226084924.16cb3e08@nehalam>
	<m1ab89m38q.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51677 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430AbZBZUYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:24:54 -0500
In-Reply-To: <m1ab89m38q.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2009 11:01:41 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > What about something like this:
> >
> > Subject: [PATCH] Avoid race between network down and sysfs
> 
> As far as solutions go.  That looks like the easiest correct solution.
> So.  
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> 
> Will -ERESTARTSYS trigger the in kernel restart logic in this case?
> 
> There are a lot more cases to cover, and I don't I like it long
> term.  Spinning waiting for rtnl_lock feels wrong.  Plus it does
> not help with discovering the problem in new sysfs, sysctl, or
> proc files.
> 
> It has the major advantage that we can fix things now.
> 

I haven't tested it, but it should restart in VFS.
Spinning is not that big a deal, and it also handles the case
where the name changed or some other race occurred during processing.
When syscall is re-entered, the name will no longer be found and
-ENOENT will be returned.
