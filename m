From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 22:08:16 +0900 (JST)
Message-ID: <20050112.220816.56650893.yoshfuji@linux-ipv6.org>
References: <20050112122300.GA12155@xi.wantstofly.org>
	<20050112125336.GH26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050112125336.GH26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050112125336.GH26856@postel.suug.ch> (at Wed, 12 Jan 2005 13:53:36 +0100), Thomas Graf <tgraf@suug.ch> says:

> * Lennert Buytenhek <20050112122300.GA12155@xi.wantstofly.org> 2005-01-12 13:23
:
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

How about adding multiple tunnels (with same ipip_bucket(t))
concurrently? :-)

--yoshfuji
