From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 20 Dec 2004 00:46:04 +0100
Message-ID: <41C612BC.5070909@tpack.net>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net> <1103497516.1046.231.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com, Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103497516.1046.231.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2004-12-19 at 17:29, Tommy Christensen wrote:
> 
>>I haven't tried this myself, but surely it can happen when the
>>socket send-buffer is smaller than what can be queued up for
>>transmission: i.e. in the qdisc queue and device DMA ring.
> 
> Shouldnt this have to do with socket options? If you wish to block while
> waiting for send, then you should be allowed.
> For a routing protocol that actually is notified that the link went
> down, it should probably flush those socket buffer at that point.

OK. So is this the recommendation for these pour souls?

  - Use a socket for each device.
  - Set the socket buffer (SO_SNDBUF) large enough. E.g. 1 MB ?
    Or use non-blocking sockets - just in case.
  - If you care about not sending stale packets, it is the
    responsibility of the application to flush the socket on
    link-down events (by down'ing the interface?).

>>Well, this is the same as what started this whole thread.
>>I believe that stopping the queue on link-down events is simply
>>bad behavior of the driver.
> 
>>From what Thomas was saying, this is not what he was doing. Read his
> email.

It was at least to the same effect. The key issue is whether the
packets are kept in the queue (qdisc) until the link is back up,
or they are drained (and dropped) by the driver.

-Tommy
