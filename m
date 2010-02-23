From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 3/3] vhost: fix get_user_pages_fast error handling
Date: Tue, 23 Feb 2010 19:43:34 +0200
Message-ID: <20100223174334.GD9834@redhat.com>
References: <cover.1266943453.git.mst@redhat.com>
 <82ba8c97ce55dd4bf9972ad755961cd14e6a0938.1266943453.git.mst@redhat.com>
 <20100223173434.GB9834@redhat.com>
 <20100223173258.GA25338@redhat.com>
 <20100223173952.GC9834@redhat.com>
 <20100223173908.GB25338@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	markmc@redhat.com, herbert.xu@redhat.com, quintela@redhat.com,
	dlaor@redhat.com, avi@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100223173908.GB25338@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2010 at 07:39:08PM +0200, Michael S. Tsirkin wrote:
> On Tue, Feb 23, 2010 at 07:39:52PM +0200, Gleb Natapov wrote:
> > On Tue, Feb 23, 2010 at 07:32:58PM +0200, Michael S. Tsirkin wrote:
> > > On Tue, Feb 23, 2010 at 07:34:34PM +0200, Gleb Natapov wrote:
> > > > On Tue, Feb 23, 2010 at 06:57:58PM +0200, Michael S. Tsirkin wrote:
> > > > > get_user_pages_fast returns number of pages on success, negative value
> > > > > on failure, but never 0. Fix vhost code to match this logic.
> > > > > 
> > > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > > ---
> > > > >  drivers/vhost/vhost.c |    3 ++-
> > > > >  1 files changed, 2 insertions(+), 1 deletions(-)
> > > > > 
> > > > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > > > index d4f8fdf..d003504 100644
> > > > > --- a/drivers/vhost/vhost.c
> > > > > +++ b/drivers/vhost/vhost.c
> > > > > @@ -646,8 +646,9 @@ static int set_bit_to_user(int nr, void __user *addr)
> > > > >  	int bit = nr + (log % PAGE_SIZE) * 8;
> > > > >  	int r;
> > > > >  	r = get_user_pages_fast(log, 1, 1, &page);
> > > > > -	if (r)
> > > > > +	if (r < 0)
> > > > >  		return r;
> > > > > +	BUG_ON(r != 1);
> > > > Can't this be easily triggered from user space?
> > > 
> > > I think no. get_user_pages_fast always returns number of pages
> > > pinned (in this case always 1) or an error (< 0).
> > > Anything else is a kernel bug.
> > > 
> > But what if page is unmapped from userspace?
> 
> Then we get -EFAULT
> 
Ah correct.

> > > > >  	base = kmap_atomic(page, KM_USER0);
> > > > >  	set_bit(bit, base);
> > > > >  	kunmap_atomic(base, KM_USER0);
> > > > > -- 
> > > > > 1.7.0.18.g0d53a5
> > > > 
> > > > --
> > > > 			Gleb.
> > 
> > --
> > 			Gleb.

--
			Gleb.
