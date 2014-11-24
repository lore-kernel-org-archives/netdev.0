From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [fuse-devel] [PATCH 4/6] fs/fuse: support compiling out splice
Date: Mon, 24 Nov 2014 12:22:14 -0800
Message-ID: <20141124202214.GA11362@kroah.com>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
 <1416752468-1626-5-git-send-email-pieter@boesman.nl>
 <CAFLxGvxq3Mr9n8xMO_fPZDhrGmBh=WKyU0+RF13JBdjssX6qfw@mail.gmail.com>
 <20141123232302.GA12456@thin>
 <20141124094931.GA1055@smipidev>
 <20141124160510.GA2446@jtriplet-mobl1>
 <20141124193412.GB31618@kroah.com>
 <20141124201450.GA18776@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pieter Smith <pieter@boesman.nl>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Bertrand Jacquin <beber@meleeweb.net>,
	Oleg Nesterov <oleg@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Eric Dumazet <edumazet@google.com>,
	=?utf-8?B?6JSh5q2j6b6Z?= <zhenglong.cai@cs2c.com.cn>,
	Jeff Layton <jlayton@poochiereds.net>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Peter Foley <pefoley2@pefoley.com>,
	Hugh Dickins <hughd@google.com>,
	Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Mel Gorman <mgorman@suse.de>, Matt Turner <mattst88@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel@lists.sourceforge.net>,
	"Luis R.
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141124201450.GA18776@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 12:14:50PM -0800, josh@joshtriplett.org wrote:
> > I would, again, argue that stuff like __splice_p() not be implemented at
> > all please.  It will only cause a huge proliferation of stuff like this
> > that will not make any sense, and only cause a trivial, if any, amount
> > of code savings.
> > 
> > I thought you were going to not do this type of thing until you got the
> > gcc optimizer working for function callbacks.
> 
> Compared to the previous patchset, there are now only two instances of
> ifdefs outside of the splice code for this, and this is one of them.  In
> this case, the issue is no longer about making the code for this
> splice_read function disappear, but rather to eliminate a reference to a
> bit of splice functionality (used *inside* the FUSE splice code) that
> will not work without SPLICE_SYSCALL.
> 
> Would you prefer to see this specific case handled via an #ifdef in
> fs/fuse/dev.c rather than introducing a __splice_p that people might be
> inclined to propagate?  That'd be fine; the code could simply wrap
> fuse_dev_splice_read in an #ifdef and have the #else define a NULL
> fuse_dev_splice_read.

Yes, I would prefer that, but I'm not the fuse maintainer.

thanks,

greg k-h
