From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Sun, 29 Jan 2012 16:37:46 -0500
Message-ID: <20120129213746.GA7164@phenom.dumpdata.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
 <20120127192214.GA14437@phenom.dumpdata.com>
 <1327844561.2911.5.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:47016 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741Ab2A3OxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:53:05 -0500
Content-Disposition: inline
In-Reply-To: <1327844561.2911.5.camel@leeds.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 29, 2012 at 01:42:41PM +0000, Wei Liu wrote:
> On Fri, 2012-01-27 at 19:22 +0000, Konrad Rzeszutek Wilk wrote:
> > On Tue, Jan 17, 2012 at 01:46:56PM +0000, Wei Liu wrote:
> > > A new netback implementation which includes three major features:
> > > 
> > >  - Global page pool support
> > >  - NAPI + kthread 1:1 model
> > >  - Netback internal name changes
> > > 
> > > Changes in V2:
> > >  - Fix minor bugs in V1
> > >  - Embed pending_tx_info into page pool
> > >  - Per-cpu scratch space
> > >  - Notification code path clean up
> > > 
> > > This patch series is the foundation of furture work. So it is better
> > > to get it right first. Patch 1 and 3 have the real meat.
> > 
> > I've been playing with these patches and couple of things
> > came to my mind: 
> >  - would it make sense to also register to the shrinker API? This way
> >    if the host is running low on memory it can squeeze it out of the
> >    pool code. Perhaps a future TODO..
> >  - I like the pool code. I was thinking that perhaps (in the future)
> >    it could be used by blkback as well, as it runs into "not enought
> >    request structure" with the default setting. And making this dynamic
> >    would be pretty sweet.
> 
> Interesting thoughts worth adding to TODO list. But I'm focusing on
> multi-page ring support and split event channel at the moment, which
> should help improve performance on 10G network. Hopefully I can submit
> RFC patch V3 in a few days. ;-)
> 
> >  - This patch set solves the CPU banding problem I've seen with the
> >    older netback. The older one  I could see X netback threads eating 80%
> >    of CPU. With this one, the number is down to 13-14%.
> > 
> > So you can definitly stick 'Tested-by: Konrad.." on them. And definitly
> > Reviewed-by on the first two - hadn't had a chance to look at the rest.
> > 
> 
> Thanks for your extensive test and review.

Sure. I also did some testing with limiting the amount of CPUs and found
that 'xl vcpu-set 0 N' make netback not work anymore :-( 
> 
> 
> Wei.
