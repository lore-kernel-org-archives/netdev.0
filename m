From: Thomas Graf <tgraf@suug.ch>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 13:53:36 +0100
Message-ID: <20050112125336.GH26856@postel.suug.ch>
References: <20050112122300.GA12155@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20050112122300.GA12155@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Lennert Buytenhek <20050112122300.GA12155@xi.wantstofly.org> 2005-01-12 13:23
> Hi!
> 
> 	static void ipip_tunnel_link(struct ipip_tunnel *t)
> 	{
> 		struct ipip_tunnel **tp = ipip_bucket(t);
> 
> 		t->next = *tp;
> 		write_lock_bh(&ipip_lock);
> 		*tp = t;
> 		write_unlock_bh(&ipip_lock);
> 	}
> 
> Shouldn't the "t->next = *tp" be done inside the write lock?

Why do you think so? linking may only happen on new tunnels
so they can't be found before they're assigned to the bucket.
dev_hold is called correctly so dev->priv usage is safe as
well.
