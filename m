From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Mon, 10 Nov 2014 12:14:10 +0200
Message-ID: <20141110101410.GA19964@redhat.com>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141107.164859.951682597018909290.davem@redhat.com>
 <20141107221114.GB7996@ZenIV.linux.org.uk>
 <20141107234253.GE7996@ZenIV.linux.org.uk>
 <20141109211908.GF7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcrl@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141109211908.GF7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 09, 2014 at 09:19:08PM +0000, Al Viro wrote:
> [Michael Cc'd]
> 
> On Fri, Nov 07, 2014 at 11:42:53PM +0000, Al Viro wrote:
> 
> > I'll finish RTFS drivers/vhost and if it turns out to be OK I'll post the
> > series moving those checks to the moment of copying iovec from userland,
> > so that kernel-side we could always rely on ->msg_iov elements having been
> > verified.
> 
> Two questions:
> 1) does sparc64 access_ok() need to differ for 32bit and 64bit tasks?
> AFAICS, x86 and ppc just check that address is OK for 64bit process -
> if a 32bit process passes the kernel an address that would be valid
> for 64bit process, but not for 32bit one, we just get a pagefault in
> __copy_from_user() and friends.  No kernel objects are going to have
> a virtual address in that range, so access_ok() doesn't bother preventing
> such access attempts there...
> 
> 2) shouldn't vhost_dev_cleanup() stop the worker thread before doing anything
> else?
>  AFAICS, we do parts of vhost_dev teardown while the thread is
> still running; granted, we keep dev->mm pinned down until after it stops
> (or we would be _really_ screwed), but is it safe to do all those fput()s, etc.
> while it's still running?  Michael?

Before invoking vhost_dev_cleanup,
the caller for vhost-net (vhost_net_release) sets private data to NULL
(using vhost_net_stop_vq) which guarantees thread will do nothing at all.
vhost scsi does it in vhost_scsi_clear_endpoint.


-- 
MST
