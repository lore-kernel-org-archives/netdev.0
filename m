From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 14:23:19 -0700 (PDT)
Message-ID: <20050510.142319.70222971.davem@davemloft.net>
References: <20050510.121214.39158393.davem@davemloft.net>
	<20050510.132642.85686818.davem@davemloft.net>
	<1115756070.8570.76.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1115756070.8570.76.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 13:14:30 -0700

> I don't think target-initiated disconnects will waste PCI bandwidth
> compared to master-initiated terminations. In both cases, you see the
> same DMA bursts across the bus, only the termination of each burst is
> different.

I think it does Michael.  Performance on sparc64 went non-trivially up
when I added the read/write boundary settings initially long ago.

You have the extra phase where the tg3 tries to start the DMA of the
next cacheline, and that is where unnecessary time is lost.  I think
it's about 2 clocks you lose if the PCI controller disconnects instead
of tg3.

Tigon3 will drive the data of the next cacheline for 1 cycle and this
is when the PCI controller will disconnect.  Tigon3 will drop the data
and respond to the disconnect sometime in the next cycle or so.

All of this activity will not occur if Tigon3 just ends the data phase
itself when the cacheline boundary is hit.

Or are you talking about PCI reads as opposed to writes?
