From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take26-resend1 0/8] kevent: Generic event handling mechanism.
Date: Tue, 12 Dec 2006 08:39:02 +0300
Message-ID: <20061212053902.GC14420@2ka.mipt.ru>
References: <1165848619971@2ka.mipt.ru> <457D764E.9040308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41091 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbWLLFjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 00:39:45 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <457D764E.9040308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 11, 2006 at 10:16:30AM -0500, Jeff Garzik (jeff@garzik.org) wrote:
> Comments:
> 
> * [oh, everybody will hate me for saying this, but...]  to me, "kevent" 
> implies an internal kernel subsystem.  I would rather call it "uevent" 
> or anything else lacking a 'k' prefix.

It is kernel subsystem indeed, which exports some of its part to
userspace.
I previously thought that prefix 'k' can only be confused with KDE.

> * I like the absolute timespec (and use of timespec itself)

And I do not, but I made them to make at least some progress.

> * more on naming:  I think kevent_open would be more natural than 
> kevent_init, since it opens a file descriptor.

It is also initializes ring buffer.

> * why is KEVENT_MAX not equal to KEVENT_POSIX_TIMER?  (perhaps answer 
> this question in a comment, if it is not a mistake)

I check for error number using '>=' and use it as array size, 
so it is always bigger than the last entry id.
I will add a comment.

> * Kill all the CONFIG_KEVENT_xxx sub-options, or hide them under 
> CONFIG_EMBEDDED.  Application developers should NOT be left wondering 
> whether or support for KEVENT_INODE was compiled into the kernel.

Ok, I will put them under !CONFIG_EMBEDDED.

-- 
	Evgeniy Polyakov
