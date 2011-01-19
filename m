From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 11:16:59 -0800
Message-ID: <4D3738AB.60701@goop.org>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>	
	<1295455216.11126.39.camel@bwh-desktop>	
	<1295459316.14981.3727.camel@zakaz.uk.xensource.com>
	<1295460304.11126.53.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@eu.citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1295460304.11126.53.camel@bwh-desktop>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 01/19/2011 10:05 AM, Ben Hutchings wrote:
> Not in itself.  NAPI polling will run on the same CPU which scheduled it
> (so wherever the IRQ was initially handled).  If the protocol used
> between netfront and netback doesn't support RSS then RPS
> <http://lwn.net/Articles/362339/> can be used to spread the RX work
> across CPUs.

There's only one irq per netback which is bound to one (V)CPU at a
time.  I guess we could extend it to have multiple irqs per netback and
some way of distributing packet flows over them, but that would only
really make sense if there's a single interface with much more traffic
than the others; otherwise the interrupts should be fairly well
distributed (assuming that the different netback irqs are routed to
different cpus).

Also, I assume that if most of the packets are not terminating in dom0
itself but are sent out some other device (either real hardware or to
another domain), then there won't be any protocol processing and the
amount of CPU required to handle the packet is minimal.  Is that true? 
And if so, would RPS help in that case? I would expect the cost of an
IPI to swamp anything else that needs to happen to the packet.

    J
