From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 13:54:16 -0800
Message-ID: <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<20050303125556.6850cfe5.davem@davemloft.net>
	<1109884688.1090.282.camel@jzny.localdomain>
	<20050303132143.7eef517c@dxpl.pdx.osdl.net>
	<1109885065.1098.285.camel@jzny.localdomain>
	<20050303133237.5d64578f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, rhee@eos.ncsu.edu, jheffner@psc.edu, Yee-Ting.Li@nuim.ie,
        baruch@ev-en.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303133237.5d64578f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Mar 2005 13:32:37 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> On 03 Mar 2005 16:24:25 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > Ok, this does sound more reasonable. Out of curiosity, are packets being
> > dropped at the socket queue? Why is "dump till empty" behaviour screwing
> > over TCP.
> 
> Because it does the same thing tail-drop in routers do.
> It makes everything back off a lot and go into slow start.
> If we'd just drop 1 packet per flow or something like that
> (so it could be fixed with a quick fast retransmit), TCP
> would avoid regressing into slow start.

Maybe a simple Random Exponential Drop (RED) would be more friendly.

> You say "use a NAPI driver", but netif_rx() _IS_ a NAPI driver.
> process_backlog() adheres to quotas and every other stabilizing
> effect NAPI drivers use, the only missing part is the RX interrupt
> disabling.
> 
> We should eliminate the max backlog thing completely.  There is
> no need for it.

Still need some bound, because if process_backlog is running slower
than the net; then the queue could grow till memory exhausted from
skbuff's. 
