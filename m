From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
 numbers
Date: Fri, 11 Sep 2009 17:13:46 -0400
Message-ID: <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <20090911204602.GA19371@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090911204602.GA19371@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-09-11 at 21:46 +0100, Jamie Lokier wrote:
> Eric Paris wrote:
> > > I would really prefer if you worked on eliminating the problem that
> > > prevents you from using netlink instead.
> > 
> > I'm not really sure if I can, although I'd love to hear input from
> > someone who knows the netlink code on how I can make it do what I need.
> > I'm really not duplicating much other than the NLMSG_OK and NLMSG_NEXT
> > macros.  My code doesn't even use skbs and I'm not savy enough to really
> > know how I could.  I'm more than willing to work on it if someone can
> > point me to how it might work.
> 
> Let's turn the question around.
> 
> Since you're doing lots of non-sockety things, and can't tolerate
> dropped packets - why isn't it a character device?  What's the reason
> for using a socket at all?
> 
> (I'm reminded of /dev/poll, /dev/epoll and /dev/inotify :-)

Originally it was a char device and I was told to use a socket protocol
so I could use get/set sockopt rather than ioctl, because ioctl is the
devil (even if those aren't THAT much better).

The queuing being done using events instead of skbs was done reusing
inotify code, reusing network code would be just as good with me.  What
I really need is a way to convey a pointer from one process to another.
That's why I claim loss is not an option, since I'm holding a reference
to the pointer I can't have that conveyance disappear under us.

If network people want me to get back out of the network system I can go
back to a char file with lots of ioctls.  I'd love to reuse code, I just
don't know what's possible...

-Eric

