From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 20 Dec 2004 20:19:42 -0500
Message-ID: <41C77A2E.3090000@pobox.com>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net>	 <1103497516.1046.231.camel@jzny.localdomain>  <41C612BC.5070909@tpack.net> <1103551830.1047.316.camel@jzny.localdomain> <41C71FFD.7090308@pobox.com> <41C76AA0.7020800@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41C76AA0.7020800@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> Jeff Garzik wrote:
> 
>> I haven't heard anything to convince me that the same change should be 
>> deployed across NNN drivers.  The drivers already signal the net core 
>> that the link is down; to me, that implies there should be code in 
>> _one_ place that handles this condition, not NNN places.
> 
> 
> AFAICS only a handful of (newer) drivers call netif_stop_queue() directly.
> Others may do this indirectly if the MAC stops taking packets from the
> DMA ringbuffer. At least some MAC's/drivers certainly don't.

Incorrect.  Use of netif_stop_queue() is -required- to signal that the 
hardware cannot accept any more skbs from the system.

Far more than a "handful" and required for all but a few very strange 
drivers.


> OK, another view on this: isn't is problematic to have skb's stuck in
> the network stack "indefinitely" ?
> They hold references to a dst_entry and a sock (and probably more).
> So how about this for the FAQ:
>  Q: Why can't I unload the af_packet module?
>  A: Ohh, you'll have to plug in the darn cable to eth0 first!
> *Please* tell me, I've got this all wrong.

You've got this all wrong.

	Jeff
