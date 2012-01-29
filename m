From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Sun, 29 Jan 2012 13:42:41 +0000
Message-ID: <1327844561.2911.5.camel@leeds.uk.xensource.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
	 <20120127192214.GA14437@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:36142 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab2A2Nxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 08:53:38 -0500
In-Reply-To: <20120127192214.GA14437@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-27 at 19:22 +0000, Konrad Rzeszutek Wilk wrote:
> On Tue, Jan 17, 2012 at 01:46:56PM +0000, Wei Liu wrote:
> > A new netback implementation which includes three major features:
> > 
> >  - Global page pool support
> >  - NAPI + kthread 1:1 model
> >  - Netback internal name changes
> > 
> > Changes in V2:
> >  - Fix minor bugs in V1
> >  - Embed pending_tx_info into page pool
> >  - Per-cpu scratch space
> >  - Notification code path clean up
> > 
> > This patch series is the foundation of furture work. So it is better
> > to get it right first. Patch 1 and 3 have the real meat.
> 
> I've been playing with these patches and couple of things
> came to my mind: 
>  - would it make sense to also register to the shrinker API? This way
>    if the host is running low on memory it can squeeze it out of the
>    pool code. Perhaps a future TODO..
>  - I like the pool code. I was thinking that perhaps (in the future)
>    it could be used by blkback as well, as it runs into "not enought
>    request structure" with the default setting. And making this dynamic
>    would be pretty sweet.

Interesting thoughts worth adding to TODO list. But I'm focusing on
multi-page ring support and split event channel at the moment, which
should help improve performance on 10G network. Hopefully I can submit
RFC patch V3 in a few days. ;-)

>  - This patch set solves the CPU banding problem I've seen with the
>    older netback. The older one  I could see X netback threads eating 80%
>    of CPU. With this one, the number is down to 13-14%.
> 
> So you can definitly stick 'Tested-by: Konrad.." on them. And definitly
> Reviewed-by on the first two - hadn't had a chance to look at the rest.
> 

Thanks for your extensive test and review.


Wei.
