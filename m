From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] netif_rx: receive path optimization
Date: 30 Mar 2005 22:16:42 -0500
Message-ID: <1112239001.1089.47.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <1112219848.1078.93.camel@jzny.localdomain>
	 <20050330155326.17cd6042@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050330155326.17cd6042@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 18:53, Stephen Hemminger wrote:

> How about percentages instead of multiple sysctl values? Or some relationship
> of max_queue and max_backlog.
> 	success  qlen < max_backlog
> 	low 	 qlen > max_backlog
> 	medium   qlen > max_queue/2
> 	high	 qlen > max_queue - max_backlog
> 	drop	 qlen > max_queue
> 

Well, you still need the moving window average computation to detect the
second order effect (of an oncoming tsunami).
Unless i misunderstood - you are suggesting looking at instantenous
values

> Also, RAND_LIE (dead code) is
> kind of confusing because I expected it to be a receive version of Random
> Drop, but it really just lies back to the caller (and keeps the packet).

If you have drivers which look at the feedback value - then they will
back off. We dont drop but we do hope that by telling the driver to back
off that it listens to us. Clearly if you have drivers that dont listen
then its like running UDP on a wire with everyone trying to shove
packets. 
For some numbers and experiments on this stuff circa 1999/2000 look at:
http://robur.slu.se/Linux/net-development/jamal/FF-html/
You may find at least one entertaining:
http://robur.slu.se/Linux/net-development/jamal/FF-html/img20.htm

cheers,
jamal
