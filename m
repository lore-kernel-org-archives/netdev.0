From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Tue, 21 Dec 2004 01:13:20 +0100
Message-ID: <41C76AA0.7020800@tpack.net>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net>	 <1103497516.1046.231.camel@jzny.localdomain>  <41C612BC.5070909@tpack.net> <1103551830.1047.316.camel@jzny.localdomain> <41C71FFD.7090308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41C71FFD.7090308@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> I haven't heard anything to convince me that the same change should be 
> deployed across NNN drivers.  The drivers already signal the net core 
> that the link is down; to me, that implies there should be code in _one_ 
> place that handles this condition, not NNN places.

AFAICS only a handful of (newer) drivers call netif_stop_queue() directly.
Others may do this indirectly if the MAC stops taking packets from the
DMA ringbuffer. At least some MAC's/drivers certainly don't.

I've always thought of netif_stop_queue() as the replacement of the old
tbusy flag, signaling a transient condition where the HW is unable to
keep up with the flow of packets. And it seems to be used for just this
in most cases.
Perhaps somebody confused netif_stop_queue with dev_deactivate() ??

OK, another view on this: isn't is problematic to have skb's stuck in
the network stack "indefinitely" ?
They hold references to a dst_entry and a sock (and probably more).
So how about this for the FAQ:
  Q: Why can't I unload the af_packet module?
  A: Ohh, you'll have to plug in the darn cable to eth0 first!
*Please* tell me, I've got this all wrong.


-Tommy
