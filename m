From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 13:01:57 -0800
Message-ID: <20050303130157.5afa4fcb@dxpl.pdx.osdl.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<20050303125556.6850cfe5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, jheffner@psc.edu, Yee-Ting.Li@nuim.ie, baruch@ev-en.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303125556.6850cfe5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Mar 2005 12:55:56 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 3 Mar 2005 12:38:11 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > The existing throttling algorithm causes all packets to be dumped
> > (until queue emptys) when the packet backlog reaches
> > netdev_max_backog. I suppose this is some kind of DoS prevention
> > mechanism. The problem is that this dumping action creates mulitple
> > packet loss that forces TCP back to slow start.
> > 
> > But, all this is really moot for the case of any reasonably high speed
> > device because of NAPI. netif_rx is not even used for any device that
> > uses NAPI.  The NAPI code path uses net_receive_skb and the receive
> > queue management is done by the receive scheduling (dev->quota) of the
> > rx_scheduler.
> 
> Even without NAPI, netif_rx() ends up using the quota etc. machanisms
> when the queue gets processed via process_backlog().
> 
> ksoftirqd should handle cpu starvation issues at a higher level.
> 
> I think it is therefore safe to remove the netif_max_backlog stuff
> altogether.  "300" is such a non-sense setting, especially for gigabit
> drivers which aren't using NAPI for whatever reason.  It's even low
> for a system with 2 100Mbit devices.

Okay, already have patchset to clean out the sample_stats and other leftovers
so I'll add it to the tail of that.
