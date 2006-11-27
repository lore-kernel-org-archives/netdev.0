From: David Miller <davem@davemloft.net>
Subject: Re: Kevent POSIX timers support.
Date: Mon, 27 Nov 2006 10:24:43 -0800 (PST)
Message-ID: <20061127.102443.74556125.davem@davemloft.net>
References: <456603E7.9090006@redhat.com>
	<20061124095052.GC13600@2ka.mipt.ru>
	<456B2C82.7040700@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org,
	chase.venters@clientec.com, johann.borck@densedata.com,
	linux-kernel@vger.kernel.org, jeff@garzik.org, aviro@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758522AbWK0SYn@vger.kernel.org>
To: drepper@redhat.com
In-Reply-To: <456B2C82.7040700@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Mon, 27 Nov 2006 10:20:50 -0800

> Evgeniy Polyakov wrote:
> >> We need to pass the data in the sigev_value meember of the struct 
> >> sigevent structure passed to timer_create to the caller.  I don't see it 
> >> being done here nor when the timer is created.  Do I miss something? 
> >> The sigev_value value should be stored in the user/ptr member of struct 
> >> ukevent.
> > 
> > sigev_value was stored in k_itimer structure, I just do not know where
> > to put it in the ukevent provided to userspace - it can be placed in
> > pointer value if you like.
> 
> sigev_value is a union and the largest element is a pointer.  So, 
> transporting the pointer value is sufficient and it should be passed up 
> to the user in the ptr member of struct ukevent.

Now we'll have to have a compat layer for 32-bit/64-bit environments
thanks to POSIX timers, which is rediculious.

This is exactly the kind of thing I was hoping we could avoid when
designing these data structures.  No pointers, no non-fixed sized
types, only types which are identically sized and aligned between
32-bit and 64-bit environments.

It's OK to have these problems for things designed a long time ago
before 32-bit/64-bit compat issues existed, but for new stuff no
way.
