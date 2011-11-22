From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
Date: Tue, 22 Nov 2011 13:38:33 +0200
Message-ID: <1321961913.3323.67.camel@lade.trondhjem.org>
References: <4EC6A681.30902@citrix.com>
	  <1321642368.2653.35.camel@lade.trondhjem.org> <4EC6AC47.60404@citrix.com>
	 <1321643673.2653.41.camel@lade.trondhjem.org> <4EC6B82B.3000701@citrix.com>
	 <4ECA94F9.4090503@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ECA94F9.4090503-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-21 at 18:14 +0000, Andrew Cooper wrote: 
> Following some debugging, I believe that the attached patch fixes the
> problem.
> 
> Simply returning EAGAIN is not sufficient, as the task does not get
> requeued, and times out 13 seconds later (as per our mount options). 
> Setting the SOCK_ASYNC_NOSPACE bit causes the requeue to happen.
> 
> I realize that this is a gross hack and I should probably not be using
> SOCK_ASYNC_NOSPACE in that way.  Is there a better way to achieve the
> same solution?
> 

What you are doing will cause the request to be put to sleep with no
guarantee that it will ever be woken up. Why would we want to do that if
there is no report of a tcp window/buffer space congestion?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
