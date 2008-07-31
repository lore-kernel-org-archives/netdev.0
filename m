From: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Thu, 31 Jul 2008 22:38:19 +1000
Message-ID: <200807312238.20264.nickpiggin@yahoo.com.au>
References: <20080726131838.GA2873@ami.dom.local> <20080727203757.GA2527@ami.dom.local> <20080731.052932.110299354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org,
	peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080731.052932.110299354.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 31 July 2008 22:29, David Miller wrote:
> From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sun, 27 Jul 2008 22:37:57 +0200
>
> > Looks like enough to me. (Probably it could even share space with
> > the state.)
>
> So I made some progress on this, three things:
>
> 1) I remember why I choose a to use a bit in my design, it's so that
>    it does not increase the costs of the checks in the fast paths.
>    test_bit(X) && test_bit(Y) can be combined into a single test by
>    the compiler.

Except for the braindead volatile that gets stuck on the bitops pointer.

Last time I complained about this, a lot of noise was made and I think
Linus wanted it to stay around so we could pass volatile pointers to
bitops & co without warnings. I say we should just remove the volatile
and kill any callers that might warn...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
