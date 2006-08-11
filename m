From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Thu, 10 Aug 2006 17:56:39 -0700
Message-ID: <20060810175639.b64faaa9.akpm@osdl.org>
References: <11551105592821@2ka.mipt.ru>
	<11551105602734@2ka.mipt.ru>
	<20060809152127.481fb346.akpm@osdl.org>
	<20060810061433.GA4689@2ka.mipt.ru>
	<20060810001844.ff5e7429.akpm@osdl.org>
	<20060810075047.GB24370@2ka.mipt.ru>
	<20060810010254.3b52682f.akpm@osdl.org>
	<20060810082235.GA21025@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40074 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932405AbWHKA5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 20:57:04 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060810082235.GA21025@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Aug 2006 12:22:35 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Thu, Aug 10, 2006 at 01:02:54AM -0700, Andrew Morton (akpm@osdl.org) wrote:
> > > > Afaict this mmap function gives a user a free way of getting pinned memory. 
> > > > What is the upper bound on the amount of memory which a user can thus
> > > > obtain?
> > > 
> > > it is limited by maximum queue length which is 4k entries right now, so
> > > maximum number of paged here is 4k*40/page_size, i.e. about 40 pages on
> > > x86.
> > 
> > Is that per user or per fd?  If the latter that is, with the usual
> > RLIMIT_NOFILE, 160MBytes.  2GB with 64k pagesize.  Problem ;)
> 
> Per kevent fd.
> I have some ideas about better mmap ring implementation, which would
> dinamically grow it's buffer when events are added and reuse the same
> place for next events, but there are some nitpics unresolved yet.
> Let's not see there in next releases (no merge of course), until better 
> solution is ready. I will change that area when other things are ready.

This is not a problem with the mmap interface per-se.  If the proposed
event code permits each user to pin 160MB of kernel memory then that would
be a serious problem.


