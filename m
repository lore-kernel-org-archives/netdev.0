From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 4 Mar 2005 14:53:17 -0800
Message-ID: <20050304145317.772859da@dxpl.pdx.osdl.net>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
	<4228D523.2070703@pobox.com>
	<20050304215044.GB1148@electric-eye.fr.zoreil.com>
	<20050304135922.0b0a3911@dxpl.pdx.osdl.net>
	<20050304221826.GA1028@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050304221826.GA1028@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Mar 2005 23:18:26 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > My pktgen script is below.
> > Sends lots of small packets.
> 
> Ok, so I have two issues...
> 
> It could help to know if it was the NAPI or the IRQ verison of the driver
> which crashed + rough estimate of the expected pkts/s count during such test.

NAPI is not enabled, it is the IRQ version. Hitting 

Added instrumentation:.

skb=0xd1e28380 len=8172 head=d1e32000 data=d1e32012 tail=d1e33ffe end=d1e32620

Looks like the board is running back-to-back packets together, MTU is 1500.
No Jumbo frames exist on my little network and the gigabit switch (Netgear) won't 
even take them.  Probably a chip bug.

Need to add a check for len > mtu before processing?
