From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 08/17] {macvtap,tun}_get_user(): switch to iov_iter
Date: Tue, 3 Feb 2015 14:27:28 +0000
Message-ID: <20150203142728.GC29656@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
 <1416924151-28698-8-git-send-email-viro@ZenIV.linux.org.uk>
 <20150203101044.GA5081@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150203101044.GA5081@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 03, 2015 at 12:10:44PM +0200, Michael S. Tsirkin wrote:

> Hmm does copy_from_iter actually modify the iovec?
> If so, won't this break aio on tun/macvtap, by
> reversing the effect of
> commit 6f26c9a7555e5bcca3560919db9b852015077dae
>     tun: fix tun_chr_aio_write so that aio works
> ?
> 
> 
> Maybe we should change iovec_iter to avoid modifying the
> underlying iovec?

iov_iter never changes the underlying iovec (or kvec, or bvec).
iter->iov_offset changes as you go and once you have consumed an
entire iovec element ->iov is incremented to point to the next one
(and ->iov_offset is reset to 0 at that point).  *Contents* of
iter->iov is never modified.
