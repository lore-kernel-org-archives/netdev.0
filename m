From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 20 Dec 2004 09:10:31 -0500
Message-ID: <1103551830.1047.316.camel@jzny.localdomain>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>
	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net>
	 <1103497516.1046.231.camel@jzny.localdomain>  <41C612BC.5070909@tpack.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com, Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41C612BC.5070909@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-19 at 18:46, Tommy Christensen wrote:

> OK. So is this the recommendation for these pour souls?
> 
>   - Use a socket for each device.

Sounds sensible (each device with IP enabled is more like it)

>   - Set the socket buffer (SO_SNDBUF) large enough. E.g. 1 MB ?
>     Or use non-blocking sockets - just in case.

I think we may need a socket "flush socket buffer" signal

>   - If you care about not sending stale packets, it is the
>     responsibility of the application to flush the socket on
>     link-down events (by down'ing the interface?).

sigh. I am begining to think this is too complex an approach.
It requires there be a way to automagically clean up the buffers
when things like this happen.

I beginuing to think thats the simplest way to achieve this: i.e not to
stop the queue but rather to let the packets continue showing up and
drop them at the driver when the link is down . The netlink async
carrier signal to the app is to be used to reroute instead of being a
signal to flush buffers. In other words the other Thomas got it right
(with the exception of setting the IFF_RUNNIGN flags)

Jeff? 

cheers,
jamal
