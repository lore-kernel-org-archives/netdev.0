From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 14:09:40 +0100
Message-ID: <20050112130940.GA12547@xi.wantstofly.org>
References: <20050112122300.GA12155@xi.wantstofly.org> <20050112125336.GH26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050112125336.GH26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2005 at 01:53:36PM +0100, Thomas Graf wrote:

> > 	static void ipip_tunnel_link(struct ipip_tunnel *t)
> > 	{
> > 		struct ipip_tunnel **tp = ipip_bucket(t);
> > 
> > 		t->next = *tp;
> > 		write_lock_bh(&ipip_lock);
> > 		*tp = t;
> > 		write_unlock_bh(&ipip_lock);
> > 	}
> > 
> > Shouldn't the "t->next = *tp" be done inside the write lock?
> 
> Why do you think so? linking may only happen on new tunnels
> so they can't be found before they're assigned to the bucket.
> dev_hold is called correctly so dev->priv usage is safe as
> well.

What if you add two tunnels at the same time?  (Or is that perhaps
synchronised on a higher level?)


--L
