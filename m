From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 08/17] {macvtap,tun}_get_user(): switch to iov_iter
Date: Tue, 3 Feb 2015 16:19:25 +0100
Message-ID: <20150203151925.GA9031@redhat.com>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
 <1416924151-28698-8-git-send-email-viro@ZenIV.linux.org.uk>
 <20150203101044.GA5081@redhat.com>
 <20150203142728.GC29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150203142728.GC29656@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 03, 2015 at 02:27:28PM +0000, Al Viro wrote:
> On Tue, Feb 03, 2015 at 12:10:44PM +0200, Michael S. Tsirkin wrote:
> 
> > Hmm does copy_from_iter actually modify the iovec?
> > If so, won't this break aio on tun/macvtap, by
> > reversing the effect of
> > commit 6f26c9a7555e5bcca3560919db9b852015077dae
> >     tun: fix tun_chr_aio_write so that aio works
> > ?
> > 
> > 
> > Maybe we should change iovec_iter to avoid modifying the
> > underlying iovec?
> 
> iov_iter never changes the underlying iovec (or kvec, or bvec).
> iter->iov_offset changes as you go and once you have consumed an
> entire iovec element ->iov is incremented to point to the next one
> (and ->iov_offset is reset to 0 at that point).  *Contents* of
> iter->iov is never modified.

I see, I think I misread the code.
Thanks for the clarification.

-- 
MST
