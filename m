From: Jeremy Martin <martinjd@csc.uvic.ca>
Subject: Re: [PATCH] fix tuntap oversight
Date: Mon, 12 Apr 2004 09:29:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040412162916.GA5046@net-ronin.org>
References: <20040412065947.GC18810@net-ronin.org> <20040412001551.05476658.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040412001551.05476658.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 12, 2004 at 12:15:51AM -0700, David S. Miller wrote:
> 
> This netif_running() check is not necessary, and in fact
> wrong.
> 
> In fact, if ethernet drivers erroneously do this, this causes
> them to fail to support the ALB bonding driver modes which
> require on-the-fly MAC address changes while the interface is
> up.
> 

I just took a look in drivers/net/
and 
	acenic.c
	atarilance.c
	b44.c
	cs89x0.c
	net_init.c
	typhoon.c

all use that netif_running() check when setting the MAC.  I actually just pulled
the function from net_init.c for the tun change.  Are these broken?
(I'm asking in total ignorance so be gentle :).

-Jeremy
