From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 26 Nov 2004 21:56:59 +0100
Message-ID: <20041126205659.GJ14782@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <1101483081.24742.174.camel@mellia.lipar.polito.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: P@draigBrady.com, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Mellia <mellia@prezzemolo.polito.it>
Content-Disposition: inline
In-Reply-To: <1101483081.24742.174.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 26, 2004 at 04:31:21PM +0100, Marco Mellia wrote:

> The point is:
> while a PCI-X linux or (or click) box can receive (receive just up to
> the netif_receive_skb() level and then discard the skb) up to more than
> wire speed using off-the-shelf gigabit ethernet hardware, there is no
> way to transmit more than about half that speed. This is true
> considering minimum sized ethernet frames.

That's more-or-less what I'm seeing.

Theoretically, the maximum #pps you can send on gigabit is p=125000000/(s+24)
where s is the packet size, and the constant 24 consists of the 8B preamble,
4B FCS and and 12B inter-frame gap.

On an e1000 in a 32b 66MHz PCI slot (Intel server mainboard, e1000 'desktop'
NIC) I'm seeing that exact curve for packet sizes > ~350 bytes, but for
smaller packets than that, the curve goes like p=264000000/(s+335)  (which
is accurate to +/- 100pps.)  The 2.64e8 component is exactly the theoretical
max. bandwidth of the PCI slot the card is in, the 335 a random constant
that accounts for latency.  On a different mobo I get a curve following
the same formula but different value for 335.

The same card in a 32b 33MHz PCI slot in a cheap Asus desktop board gives
something a bit stranger:
- p=132000000/(s+260) for s<128
- p=132000000/(s+390) for 128<=s<256
- p=132000000/(s+520) for 256<=s<384
- ...

Again, the 132000000 corresponds with the theoretical max. bandwidth of
the 32/33 bus.  I'm not all that sure yet why things show this behavior.


--L
