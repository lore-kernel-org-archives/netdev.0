From: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Subject: Re: [fuse-devel] [PATCH 4/6] fs/fuse: support compiling out splice
Date: Mon, 24 Nov 2014 22:49:26 +0100
Message-ID: <20141124214926.GA9371@smipidev>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
 <1416752468-1626-5-git-send-email-pieter@boesman.nl>
 <CAFLxGvxq3Mr9n8xMO_fPZDhrGmBh=WKyU0+RF13JBdjssX6qfw@mail.gmail.com>
 <20141123232302.GA12456@thin>
 <20141124094931.GA1055@smipidev>
 <20141124160510.GA2446@jtriplet-mobl1>
 <20141124193412.GB31618@kroah.com>
 <20141124201450.GA18776@cloud>
 <20141124202214.GA11362@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
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
	"Luis R. Rodriguez"
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141124202214.GA11362-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 12:22:14PM -0800, Greg KH wrote:
> On Mon, Nov 24, 2014 at 12:14:50PM -0800, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org wrote:
> > > I would, again, argue that stuff like __splice_p() not be implemented at
> > > all please.  It will only cause a huge proliferation of stuff like this
> > > that will not make any sense, and only cause a trivial, if any, amount
> > > of code savings.
> > > 
> > > I thought you were going to not do this type of thing until you got the
> > > gcc optimizer working for function callbacks.
> > 
> > Compared to the previous patchset, there are now only two instances of
> > ifdefs outside of the splice code for this, and this is one of them.  In
> > this case, the issue is no longer about making the code for this
> > splice_read function disappear, but rather to eliminate a reference to a
> > bit of splice functionality (used *inside* the FUSE splice code) that
> > will not work without SPLICE_SYSCALL.
> > 
> > Would you prefer to see this specific case handled via an #ifdef in
> > fs/fuse/dev.c rather than introducing a __splice_p that people might be
> > inclined to propagate?  That'd be fine; the code could simply wrap
> > fuse_dev_splice_read in an #ifdef and have the #else define a NULL
> > fuse_dev_splice_read.
> 
> Yes, I would prefer that, but I'm not the fuse maintainer.
> 
> thanks,
> 
> greg k-h

Okay. I'll do my part to prevent the type of proliferation guaranteed to rate
high on the respected K-H icky-scale. __splice_p() goes the way of the dodo
in favor of the solution presented by Josh.

I pray that the Gods of fuse maintenance will look favorable upon the result.
