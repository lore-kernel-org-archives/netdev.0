From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: fs: Use non-const iov in aio_read/aio_write
Date: Mon, 3 Nov 2014 00:21:39 +0000
Message-ID: <20141103002139.GW7996@ZenIV.linux.org.uk>
References: <20141102230552.GA26095@gondor.apana.org.au>
 <20141103001634.GV7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141103001634.GV7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2014 at 12:16:34AM +0000, Al Viro wrote:

> NAK with extreme prejudice.  The right way to deal with that is
> to convert the socket side of things to iov_iter.  And give it a
> consistent behaviour, while we are at it (some protocols do advance
> the damn thing, so do not).  There are _very_ good reasons to have those
> iovecs unchanged - if you look at the callers on the socket side, you'll
> see a bunch that has to _copy_ iovec just to avoid it being buggered.
> And you get rather suboptimal behaviour in memcpy_fromiovec() and friends,
> exactly because you have to skip through the emptied elements.
> 
> IOW, no way in hell.

PS: I do have the beginning of that stuff sitting in the local queue since
April; see http://marc.info/?l=linux-xfs&m=139179304710494&w=2 for the
beginning of the story.
