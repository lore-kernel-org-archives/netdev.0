From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take23 3/5] kevent: poll/select() notifications.
Date: Wed, 8 Nov 2006 20:03:59 +0300
Message-ID: <20061108170358.GA27557@2ka.mipt.ru>
References: <11629182482792@2ka.mipt.ru> <Pine.LNX.4.64.0611071449410.17731@alien.or.mcafeemobile.com> <20061108084554.GD2447@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:17301 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1753271AbWKHRGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 12:06:11 -0500
To: Davide Libenzi <davidel@xmailserver.org>
Content-Disposition: inline
In-Reply-To: <20061108084554.GD2447@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 08, 2006 at 11:45:54AM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Are you sure you can safely call file->f_op->poll() from inside a callback 
> > based wakeup? The low level driver may be calling the wakeup with one of 
> > its locks held, and during the file->f_op->poll may be trying to acquire 
> > the same lock. I remember there was a discussion about this, and assuming 
> > the above not true, made epoll code more complex (and slower, since an 
> > extra O(R) loop was needed to fetch events).
> 
> Indeed, I have not paid too much attention to poll/select notifications in 
> kevent actually. As far as I recall it should be called on behalf of process 
> doing kevent_get_event(). I will check and fix if that is not correct.
> Thanks Davide.

Indeed there was a bug.
Actually poll/select patch was broken quite noticebly - patchset did not
include major changes I made for it.
I will put them all into next release.

Thanks again Davide for pointing that out.

-- 
	Evgeniy Polyakov
