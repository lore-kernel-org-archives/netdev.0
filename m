From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Fri, 22 Apr 2005 19:14:40 -0700
Message-ID: <20050423021440.GZ21897@waste.org>
References: <4.454130102@selenic.com> <5.454130102@selenic.com> <17001.31150.194263.732284@segfault.boston.redhat.com> <20050422155218.223fa84d.davem@davemloft.net> <17001.33427.462497.856777@segfault.boston.redhat.com> <20050422155958.474a150c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmoyer@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050422155958.474a150c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 03:59:58PM -0700, David S. Miller wrote:
> On Fri, 22 Apr 2005 19:02:43 -0400
> Jeff Moyer <jmoyer@redhat.com> wrote:
> 
> > Oh yes, of course.  Somehow I managed to forget that we now squirrel away
> > the struct netpoll pointer in the net_device.  Previously you could
> > register multiple netpoll clients to one device, and this was useful for
> > say doing netconsole and netdump over the same interface.  If we've removed
> > this ability, this is a bad thing.  Oh dear...

Hrm, it appears I forgot about that when I did the recent rework.

> In such a configuration, how did the netpoll code "tell" who the
> receive packets were for or did it send them to all registered
> netpoll clients for that device?

It walked a global list of clients.

-- 
Mathematics is the supreme nostalgia of our time.
