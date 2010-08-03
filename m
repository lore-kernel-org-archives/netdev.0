From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet
 loss
Date: Tue, 3 Aug 2010 02:11:10 -0700
Message-ID: <20100803021110.f0b3877b.akpm@linux-foundation.org>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
	<20100803.012144.267950450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andyc.bluearc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, William.Allen.Simpson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	gilad-f4XOiQkOAtcdH0auuBZGHA@public.gmane.org, ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100803.012144.267950450.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(cc linux-nfs)

On Tue, 03 Aug 2010 01:21:44 -0700 (PDT) David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: "Andy Chittenden" <andyc.bluearc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 3 Aug 2010 09:14:31 +0100
> 
> > I don't know whether this patch is the correct fix or not but it enables the
> > NFS client to recover.
> > 
> > Kernel version: 2.6.34.1 and 2.6.32.
> > 
> > Fixes <https://bugzilla.kernel.org/show_bug.cgi?id=16494>. It clears down
> > any previous shutdown attempts so that reconnects on a socket that's been
> > shutdown leave the socket in a usable state (otherwise tcp_sendmsg() returns
> > -EPIPE).
> 
> If the SunRPC code wants to close a TCP socket then use it again,
> it should disconnect by doing a connect() with sa_family == AF_UNSPEC
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
