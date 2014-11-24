From: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
Subject: Re: [fuse-devel] [PATCH 4/6] fs/fuse: support compiling out splice
Date: Mon, 24 Nov 2014 12:14:50 -0800
Message-ID: <20141124201450.GA18776@cloud>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
 <1416752468-1626-5-git-send-email-pieter@boesman.nl>
 <CAFLxGvxq3Mr9n8xMO_fPZDhrGmBh=WKyU0+RF13JBdjssX6qfw@mail.gmail.com>
 <20141123232302.GA12456@thin>
 <20141124094931.GA1055@smipidev>
 <20141124160510.GA2446@jtriplet-mobl1>
 <20141124193412.GB31618@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?utf-8?B?6JSh5q2j6b6Z?= <zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>,
	Peter Foley <pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Xiao Guangrong <xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"Luis R.
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141124193412.GB31618-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 11:34:12AM -0800, Greg KH wrote:
> On Mon, Nov 24, 2014 at 08:05:10AM -0800, Josh Triplett wrote:
> > On Mon, Nov 24, 2014 at 10:49:31AM +0100, Pieter Smith wrote:
> > > On Sun, Nov 23, 2014 at 03:23:02PM -0800, Josh Triplett wrote:
> > > > On Sun, Nov 23, 2014 at 11:29:08PM +0100, Richard Weinberger wrote:
> > > > > On Sun, Nov 23, 2014 at 3:20 PM, Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org> wrote:
> > > > > > To implement splice support, fs/fuse makes use of nosteal_pipe_buf_ops. This
> > > > > > struct is exported by fs/splice. The goal of the larger patch set is to
> > > > > > completely compile out fs/splice, so uses of the exported struct need to be
> > > > > > compiled out along with fs/splice.
> > > > > >
> > > > > > This patch therefore compiles out splice support in fs/fuse when
> > > > > > CONFIG_SYSCALL_SPLICE is undefined.
> > > > > >
> > > > > > Signed-off-by: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
> > > > > > ---
> > > > > >  fs/fuse/dev.c      | 4 ++--
> > > > > >  include/linux/fs.h | 6 ++++++
> > > > > >  2 files changed, 8 insertions(+), 2 deletions(-)
> > > > > >
> > > > > > diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
> > > > > > index ca88731..f8f92a4 100644
> > > > > > --- a/fs/fuse/dev.c
> > > > > > +++ b/fs/fuse/dev.c
> > > > > > @@ -1291,7 +1291,7 @@ static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
> > > > > >         return fuse_dev_do_read(fc, file, &cs, iov_length(iov, nr_segs));
> > > > > >  }
> > > > > >
> > > > > > -static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
> > > > > > +static ssize_t __maybe_unused fuse_dev_splice_read(struct file *in, loff_t *ppos,
> > > > > >                                     struct pipe_inode_info *pipe,
> > > > > >                                     size_t len, unsigned int flags)
> > > > > >  {
> > > > > > @@ -2144,7 +2144,7 @@ const struct file_operations fuse_dev_operations = {
> > > > > >         .llseek         = no_llseek,
> > > > > >         .read           = do_sync_read,
> > > > > >         .aio_read       = fuse_dev_read,
> > > > > > -       .splice_read    = fuse_dev_splice_read,
> > > > > > +       .splice_read    = __splice_p(fuse_dev_splice_read),
> > > > > >         .write          = do_sync_write,
> > > > > >         .aio_write      = fuse_dev_write,
> > > > > >         .splice_write   = fuse_dev_splice_write,
> > > > > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > > > > index a957d43..04c0975 100644
> > > > > > --- a/include/linux/fs.h
> > > > > > +++ b/include/linux/fs.h
> > > > > > @@ -2443,6 +2443,12 @@ extern int blkdev_fsync(struct file *filp, loff_t start, loff_t end,
> > > > > >                         int datasync);
> > > > > >  extern void block_sync_page(struct page *page);
> > > > > >
> > > > > > +#ifdef CONFIG_SYSCALL_SPLICE
> > > > > > +#define __splice_p(x) x
> > > > > > +#else
> > > > > > +#define __splice_p(x) NULL
> > > > > > +#endif
> > > > > > +
> > > > > 
> > > > > This needs to go into a different patch.
> > > > > One logical change per patch please. :-)
> > > > 
> > > > Easy enough to merge this one into the patch introducing
> > > > CONFIG_SYSCALL_SPLICE, then.
> > > > 
> > > > - Josh Triplett
> > > 
> > > The patch introducing CONFIG_SYSCALL_SPLICE (PATCH 3) only compiles out the
> > > syscalls. PATCH 6 on the other hand, compiles out fs/splice.c. This patch
> > > allows fs/fuse to be compiled when fs/splice.c is compiled out. If I am to
> > > squash it, it would be logical to include it in PATCH 6, not 3.
> > 
> > The suggestion wasn't to move the fs/fuse/dev.c bits; those should
> > definitely stay in this patch.  The suggestion was just to move the bit
> > of the patch defining __splice_p from this patch to patch 3.  (Note that
> > you need to define it before you use it, so it can't go in patch 6.)
> 
> I would, again, argue that stuff like __splice_p() not be implemented at
> all please.  It will only cause a huge proliferation of stuff like this
> that will not make any sense, and only cause a trivial, if any, amount
> of code savings.
> 
> I thought you were going to not do this type of thing until you got the
> gcc optimizer working for function callbacks.

Compared to the previous patchset, there are now only two instances of
ifdefs outside of the splice code for this, and this is one of them.  In
this case, the issue is no longer about making the code for this
splice_read function disappear, but rather to eliminate a reference to a
bit of splice functionality (used *inside* the FUSE splice code) that
will not work without SPLICE_SYSCALL.

Would you prefer to see this specific case handled via an #ifdef in
fs/fuse/dev.c rather than introducing a __splice_p that people might be
inclined to propagate?  That'd be fine; the code could simply wrap
fuse_dev_splice_read in an #ifdef and have the #else define a NULL
fuse_dev_splice_read.

- Josh Triplett
