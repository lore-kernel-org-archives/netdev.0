From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add a synchronize_net() in
 netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 06:38:59 -0700
Message-ID: <1364564339.5113.19.camel@edumazet-glaptop>
References: <1364490997.6345.237.camel@gandalf.local.home>
	 <1364491792.15753.47.camel@edumazet-glaptop>
	 <20130329094856.GB1677@minipsycho.orion>
	 <1364562082.5113.16.camel@edumazet-glaptop>
	 <1364563039.10629.19.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>, stephen@networkplumber.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364563039.10629.19.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-03-29 at 09:17 -0400, Steven Rostedt wrote:

> I've thought about this too, but I wasn't sure we wanted two
> synchronize_*() functions, as the caller does a synchronize as well.
> That said, I think this is the more robust solution and it lets all
> rx_handler() functions assume that their rx_handler_data is set. And it
> removes the check from the fast path which outweighs an added
> synchronization in the slow path.
> 

Note that I used synchronize_net(), which does a
synchronize_rcu_expedited() when RTNL is locked, so its normally quite
fast.

> Acked-by: Steven Rostedt <rostedt@goodmis.org>
> 
> Thanks!

Thanks a lot for your very detailed report and analysis !
