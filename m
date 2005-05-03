From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Mystery packet killing tg3
Date: Mon, 2 May 2005 20:02:51 -0700
Message-ID: <20050502200251.38271b61.davem@davemloft.net>
References: <20050502162405.65dfb4a9@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050502162405.65dfb4a9@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 May 2005 16:24:05 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> While I was on vacation, OSDL did some networking changes that seems to aggravate some
> existing bug in the tg3 driver. Could be some VLAN related garbage, not sure.
> 
> System is 2 CPU AMD64 and the tg3 is on the motherboard.
> 
> I am seeing messages like:
>  eth0: Tigon3 [partno(BCM95703A30) rev 1002 PHY(5703)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:60:53:08:18
>  eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0] 
>  tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2
> 
> Any clues?

This usually means that there is some DMA corruption.
For example, some bug in the x86_64 IOMMU code or similar
causes a bogus DMA address to be fed to the tg3 or even
worse a DMA mapping is unmapped before tg3 is actually
done with it.

Please try to get some more debugging.  One thing that might
be useful would be a dump of the PCI config and PCI status
registers from PCI config space when that tg3_stop_block
event triggers.  It will tell us if there was a master or
slave abort on the PCI bus which would confirm my above
theory.

Also what PCI controller is in this box?  (ie. the north bridge,
lspci -v would tell)

Since AMD promised me an Opteron system last year, but never
made good on that promise, I've never been able to work on
fixing this bug myself. :-/
