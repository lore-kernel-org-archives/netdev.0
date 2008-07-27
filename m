From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Sun, 27 Jul 2008 22:37:57 +0200
Message-ID: <20080727203757.GA2527@ami.dom.local>
References: <20080725200137.GC3107@ami.dom.local> <20080726.021846.236624483.davem@davemloft.net> <20080726131838.GA2873@ami.dom.local> <20080726.173434.48036095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080726.173434.48036095.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 26, 2008 at 05:34:34PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sat, 26 Jul 2008 15:18:38 +0200
> 
> > I guess some additional synchronization will be added yet to prevent
> > parallel freeze and especially unfreeze.
> 
> Yes, that could be a problem.  Using test_and_set_bit() can
> guard the freezing sequence itself, but it won't handle
> letting two threads of control freeze and unfreeze safely
> without a reference count.
> 
> We want this thing to be able to be used flexbly, which means
> we can't just assume that this is a short code sequence and
> the unfreeze will come quickly.  That pretty much rules
> out using a new lock around the operation or anything
> like that.
> 
> So I guess we could replace the state bit with a reference
> count.  It doesn't even need to be atomic since it is set
> and tested under dev_queue->_xmit_lock
 
Looks like enough to me. (Probably it could even share space with
the state.)

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
