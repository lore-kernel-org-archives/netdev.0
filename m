From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 22 Dec 2004 08:48:28 -0500
Message-ID: <1103723307.1092.83.camel@jzny.localdomain>
References: <OFD729E7DA.203E1D4A-ONC1256F72.003B7A8E-C1256F72.003C1150@de.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Spatzier <thomas.spatzier@de.ibm.com>
In-Reply-To: <OFD729E7DA.203E1D4A-ONC1256F72.003B7A8E-C1256F72.003C1150@de.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-22 at 05:56, Thomas Spatzier wrote:

> 
> Is that ok, i.e. what all drivers do or should do?
> 
> For the problems that applications might have (i.e. sockets being
> blocked etc.) another solution should be found.
> And as Jeff pointed out, this should be a central solution and
> not be implemented in drivers.
> 

I think this needs to be resolved too. 
It is possible to have a centralized action instead of requiring drivers
to make changes if we know the state of the driver is in netcarrier_off.
What that would require is 
on cable gone, you just say:
      netif_carrier_off();
and the top layer code will junk the packets before they hit the driver.
This way the socket code can continue sending whatever it wants but if
theres no link, then its fair to drop those packets?

If this acceptable i can generate a quick patch.

cheers,
jamal
