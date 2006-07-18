From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 23:11:37 +0400
Message-ID: <20060718191137.GB28540@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <200607181316.18461.borntrae@de.ibm.com> <20060718115125.GA6087@2ka.mipt.ru> <200607181436.57841.borntrae@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59834 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932380AbWGRUF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 16:05:28 -0400
To: Christian Borntraeger <borntrae@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200607181436.57841.borntrae@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 02:36:57PM +0200, Christian Borntraeger (borntrae@de.ibm.com) wrote:
> On Tuesday 18 July 2006 13:51, Evgeniy Polyakov wrote:
> > > I think this should be -EFAULT instead of -ERESTARTSYS, right?
> >
> > I have no strong feeling on what must be returned in that case.
> > As far as I see, copy*user can fail due to absence of the next
> > destination page, so -ERESTARTSYS makes sence, but if failure happens due
> > to process size limitation, -EFAULT is correct.
> 
> If I am not completely mistaken ERESTARTSYS is wrong. 
> include/linux/errno.h says userspace should never see ERESTARTSYS, therefore 
> we should only return it if we were interrupted by a signal as do_signal 
> takes care of ERESTARTSYS. Furthermore, copy*user transparently faults in 
> necessary pages as long as the address is valid in the user context. 

Actually userspace will not see ERESTARTSYS, when it is returned from
syscall.

> > Let's change it to -EFAULT.
> 
> Thanks :-)

No problem. I've commited this change already.
 
> -- 
> Mit freundlichen Gr????en / Best Regards
> 
> Christian Borntraeger
> Linux Software Engineer zSeries Linux & Virtualization

-- 
	Evgeniy Polyakov
