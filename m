From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 3 Mar 2005 13:39:11 -0800
Message-ID: <20050303213911.GV3120@waste.org>
References: <7.454130102@selenic.com> <8.454130102@selenic.com> <20050303130031.066f0862.davem@davemloft.net> <42277ED6.4020707@pobox.com> <20050303132906.2b5d597f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com, jmoyer@redhat.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050303132906.2b5d597f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2005 at 01:29:06PM -0800, David S. Miller wrote:
> On Thu, 03 Mar 2005 16:17:10 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Heh, I was just writing this same message.
> > 
> > On a related note...  David, I would prefer if you merged up the netpoll 
> > stuff, since it touches mainly net/*
> > 
> > Is that cool w/ you?
> 
> No problem.  I still don't like this code in that it adds a locking
> penalty to everyone just by virtue of enabling netpoll.  We've worked
> so hard with things like NETIF_F_LLTX to eliminate locking, so this
> would be a huge step backwards.

The lock only happens if CONFIG_NETPOLL=y _and_ a netpoll client (eg
netconsole) is registered on the device in question.

I'm certainly open to ideas that improve upon that, but everything
I've come up with is equivalent in cost to a lock.

-- 
Mathematics is the supreme nostalgia of our time.
