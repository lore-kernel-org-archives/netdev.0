From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] pktgen handle netdev device getting full.
Date: Thu, 16 Sep 2004 16:20:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916162051.1b55ae5b@dell_ss3.pdx.osdl.net>
References: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>
	<414A1AD2.1090109@candelatech.com>
	<20040916155913.577b878b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, Robert.Olsson@data.slu.se,
        davem@redhat.com, netdev@oss.sgi.com, hadi@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040916155913.577b878b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 15:59:13 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 16 Sep 2004 15:59:30 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> > Stephen Hemminger wrote:
> > > I was trying out pktgen on a NIC with an undersized ring, so 
> > > hard_start_xmit would always return non-zero when full.  This caused a slew
> > > of console messages.  Better to just have pktgen retry in this case.
> > 
> > My understanding is that if the queue is not stopped, then you
> > should not get the hard xmit errors.  So, in a proper driver,
> > you should not see these printks.

Well the E1000 fill's it Tx ring and returns TX_BUSY, and on
SMP can also get TX_LOCKED now.  If that happens, the message shows up.
Several other drivers don't set stopped when ring is almost full, but
rely on scheduler to do it for them.


> That is absolutely correct, that is why Stephen's patch is
> not correct (aside from the do_div() part which I'll happily
> apply if submitted by itself).
> 
> > By the way, is there any interest in adding my patch that also allows
> > pktgen to receive packets (and count the statistics, etc)?  I know
> > DaveM objected to the hook in the skb-receive logic some time back,
> > but maybe he has a different opinion now?
> 
> I still object to this, it will be abused.

Robert also has a new version of pktgen but he wanted to hold off till
2.7, but now that 2.7 is delayed maybe it should come sooner.
