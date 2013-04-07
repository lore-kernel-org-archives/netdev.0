From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 4/5] tipc: add InfiniBand media type
Date: Sun, 7 Apr 2013 14:04:30 +0200
Message-ID: <20130407120430.GA23134@macbook.localnet>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
 <1364993010-15515-5-git-send-email-kaber@trash.net>
 <51613740.6050501@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org, allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ying Xue <ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51613740.6050501-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 07, 2013 at 05:07:12PM +0800, Ying Xue wrote:
> 
> > --- a/net/tipc/core.c
> > +++ b/net/tipc/core.c
> > @@ -82,6 +82,7 @@ static void tipc_core_stop_net(void)
> >  {
> >  	tipc_net_stop();
> >  	tipc_eth_media_stop();
> > +	tipc_ib_media_stop();
> >  }
> >  
> >  /**
> > @@ -93,8 +94,17 @@ int tipc_core_start_net(unsigned long addr)
> >  
> >  	tipc_net_start(addr);
> >  	res = tipc_eth_media_start();
> > -	if (res)
> > -		tipc_core_stop_net();
> > +	if (res < 0)
> > +		goto err1;
> > +	res = tipc_ib_media_start();
> > +	if (res < 0)
> > +		goto err2;
> > +	return res;
> > +
> > +err2:
> > +	tipc_eth_media_stop();
> 
> Why do we need to call tipc_eth_media_stop() separately?
> In any failed case, we will finally invoke tipc_core_stop_net() which
> already places tipc_eth_media_stop().

Right, that's not necessary, although I think its cleaner to do have error
handling just be the opposite of initialization, IOW calling tipc_net_stop()
instead of tipc_core_stop_net().

But I don't care much either way, will fix this up for the next submission,
thanks.

> 
> > +err1:
> > +	tipc_core_stop_net();
> >  	return res;
> >  }
> >  
> 
> Regards,
> Ying
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
