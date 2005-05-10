From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 13:49:39 -0700
Message-ID: <1115758179.8570.79.camel@rh4>
References: <20050510.121214.39158393.davem@davemloft.net>
 <20050510.132642.85686818.davem@davemloft.net>
 <1115756070.8570.76.camel@rh4>
 <20050510.142319.70222971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050510.142319.70222971.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-10 at 14:23 -0700, David S.Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Subject: Re: tg3 support broken on PPC, a workaround
> Date: Tue, 10 May 2005 13:14:30 -0700
> 
> > I don't think target-initiated disconnects will waste PCI bandwidth
> > compared to master-initiated terminations. In both cases, you see the
> > same DMA bursts across the bus, only the termination of each burst is
> > different.
> 
> I think it does Michael.  Performance on sparc64 went non-trivially up
> when I added the read/write boundary settings initially long ago.
> 
> You have the extra phase where the tg3 tries to start the DMA of the
> next cacheline, and that is where unnecessary time is lost.  I think
> it's about 2 clocks you lose if the PCI controller disconnects instead
> of tg3.
> 
> Tigon3 will drive the data of the next cacheline for 1 cycle and this
> is when the PCI controller will disconnect.  Tigon3 will drop the data
> and respond to the disconnect sometime in the next cycle or so.
> 

You're right. This is Disconnect Without Data and it does cost a few
clock cycles compared to Disconnect With Data or master initiated
termination.
