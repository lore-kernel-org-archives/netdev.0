From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Mon, 12 Jun 2017 10:47:09 +0200
Message-ID: <20170612084709.GA3242@salvia>
References: <20170530093812.10712-1-fw@strlen.de>
 <87y3tcj3n7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:56627 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdFLIrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 04:47:16 -0400
Content-Disposition: inline
In-Reply-To: <87y3tcj3n7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 01:13:32PM -0500, Eric W. Biederman wrote:
> Florian Westphal <fw@strlen.de> writes:
> 
> > Quoting Joe Stringer:
> >   If a user loads nf_conntrack_ftp, sends FTP traffic through a network
> >   namespace, destroys that namespace then unloads the FTP helper module,
> >   then the kernel will crash.
> >
> > Events that lead to the crash:
> > 1. conntrack is created with ftp helper in netns x
> > 2. This netns is destroyed
> > 3. netns destruction is scheduled
> > 4. netns destruction wq starts, removes netns from global list
> > 5. ftp helper is unloaded, which resets all helpers of the conntracks
> > via for_each_net()
> >
> > but because netns is already gone from list the for_each_net() loop
> > doesn't include it, therefore all of these conntracks are unaffected.
> >
> > 6. helper module unload finishes
> > 7. netns wq invokes destructor for rmmod'ed helper
> >
> > CC: "Eric W. Biederman" <ebiederm@xmission.com>
> > Reported-by: Joe Stringer <joe@ovn.org>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Eric, I'd like an explicit (n)ack from you for this one.
> 
> This doesn't look too scary but I have the impression we have addressed
> this elsewhere with a different solution.

Eric, so you hold your nose there and I take this ;-)

Or let me know if you want a different path.

Thanks !
