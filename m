From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: ip6_dst_lookup_tail oops
Date: Fri, 18 Jan 2013 13:25:34 -0500
Message-ID: <20130118182534.GB15977@hmsreliant.think-freely.org>
References: <20130116145507.GA12244@redhat.com>
 <20130117152504.GC32586@redhat.com>
 <20130118124809.GA15977@hmsreliant.think-freely.org>
 <20130118152023.GA2116@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53558 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab3ARSZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 13:25:46 -0500
Content-Disposition: inline
In-Reply-To: <20130118152023.GA2116@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 10:20:23AM -0500, Dave Jones wrote:
> On Fri, Jan 18, 2013 at 07:48:09AM -0500, Neil Horman wrote:
>  > > Now I've hit it with rt->n = 2000000000000010. So I'm starting to
>  > > think this is getting passed in directly from userspace somehow, as
>  > > these values look like the output of my 'set a few random bits' routine
>  > > that sometimes gets called for params.
>  > > 
>  > > I'm having trouble mapping a corrupt sendmsg parameter to a messed up rt->n though.
>  > > 
>  > Well, neighbor table entries for ipv6 get added over rtnetlink,
> 
> ah, that's helpful. That explains why just fuzzing sendmsg alone won't hit this.
> 
Yeah, I expect the failure is going to be preceded by a RTM_NEWNEIGH message at
some point, or possibly some combination of RTM_NEWNEIGH and RTM_ROUTE that
erroneously sets up that bogus neighbor pointer.

>  > but it seems you
>  > would have to be able to memory map the socket to get a pointer like that into
>  > place.  Trinity doesn't record the syscalls it makes does it?  That might be
>  > helpful in tracking this down.
> 
> It does, but when it takes two days to hit something like this, you end up
> with gigabytes of data to look through.
> 
Yeah, thats a bit much.  I suppose at this point I'd suggest running a stap
script or just modifying the kernel to dump the neighbour table every time you
add a neighbor entry in __neigh_create.  That might at least get us closer to
the point at which we introduce the problem.

Best
Neil

> 	Dave
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
