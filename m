From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 26 Nov 2004 22:02:07 +0100
Message-ID: <20041126210207.GK14782@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <1101483081.24742.174.camel@mellia.lipar.polito.it> <20041126205659.GJ14782@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: P@draigBrady.com, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Mellia <mellia@prezzemolo.polito.it>
Content-Disposition: inline
In-Reply-To: <20041126205659.GJ14782@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 26, 2004 at 09:56:59PM +0100, Lennert Buytenhek wrote:

> On an e1000 in a 32b 66MHz PCI slot (Intel server mainboard, e1000 'desktop'
> NIC) I'm seeing that exact curve for packet sizes > ~350 bytes, but for
> smaller packets than that, the curve goes like p=264000000/(s+335)  (which
> is accurate to +/- 100pps.)  The 2.64e8 component is exactly the theoretical
> max. bandwidth of the PCI slot the card is in, the 335 a random constant
> that accounts for latency.  On a different mobo I get a curve following
> the same formula but different value for 335.
> 
> The same card in a 32b 33MHz PCI slot in a cheap Asus desktop board gives
> something a bit stranger:
> - p=132000000/(s+260) for s<128
> - p=132000000/(s+390) for 128<=s<256
> - p=132000000/(s+520) for 256<=s<384
> - ...

This could be explained by observing that on the Intel mobo, the NIC sits
on a dedicated PCI bus, while on the cheap Asus board, all PCI slots plus
all onboard devices share the same PCI bus.  Probably after pulling in a
single burst of packet (32 clocks here, sounds about right), the NIC has
to relinquish the bus to other bus masters and wait for 128 byte times
until it gets to pull packet data from RAM again.

Would be interesting to find out where the latency is coming from.  Find
a way to reduce/work around that and the 64b packet case will benefit as
well.


--L
