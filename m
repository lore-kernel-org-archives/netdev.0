From: David Miller <davem@davemloft.net>
Subject: Re: [take2 1/4] kevent: core files.
Date: Tue, 01 Aug 2006 17:01:38 -0700 (PDT)
Message-ID: <20060801.170138.107248641.davem@davemloft.net>
References: <11544248451203@2ka.mipt.ru>
	<44CFEA4B.3060200@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org,
	drepper@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750838AbWHBACh@vger.kernel.org>
To: zach.brown@oracle.com
In-Reply-To: <44CFEA4B.3060200@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@oracle.com>
Date: Tue, 01 Aug 2006 16:56:59 -0700

> Even if we only have one syscall with a cmd multiplexer (which I'm not
> thrilled with), we should at least make these arguments explicit in the
> system call.  It's weird to hide them in a struct.  We could also think
> about making them u32 or u64 so that we don't need compat wrappers, but
> maybe that's overkill.

I think making the userspace data structure not require any compat
handling is a must, thanks for pointing this out Zach.

> It'd be great if these struct members could get a prefix (ala: inode ->
> i_, socket -> sk_) so that it's less painful getting tags helpers to
> look up instances for us.  Asking for 'lock' is hilarious.

Agreed.

> Hmm.  I think the current preference is not to have a lock per bucket.

Yes, it loses badly, that's why we undid this in the routing cache
and just have a fixed sized array of locks which is hashed into.

For kevents, I think a single spinlock initially is fine and
if we hit performance problems on SMP we can fix it.  We should
not implement complexity we have no proof of needing yet :)

> > +#define KEVENT_MAX_REQUESTS		PAGE_SIZE/sizeof(struct kevent)
> 
> This is unused?

It is probably groundwork for the mmap() ring buffer... :)
