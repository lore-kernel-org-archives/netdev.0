From: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 22 Dec 2004 11:56:06 +0100
Message-ID: <OFD729E7DA.203E1D4A-ONC1256F72.003B7A8E-C1256F72.003C1150@de.ibm.com>
References: <41C71FFD.7090308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <41C71FFD.7090308@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Jeff Garzik <jgarzik@pobox.com> wrote on 20.12.2004 19:54:53:
> I haven't heard anything to convince me that the same change should be
> deployed across NNN drivers.  The drivers already signal the net core
> that the link is down; to me, that implies there should be code in _one_
> place that handles this condition, not NNN places.
>

This sounds plausible and I'm with Jeff here.
For me as the driver author it's the smallest change.
I will put it like this:
on cable gone:
      netif_stop_queue();
      netif_carrier_off();
on cable reconnected:
      netif_carrier_on();
      netif_wake_queue();

Is that ok, i.e. what all drivers do or should do?

For the problems that applications might have (i.e. sockets being
blocked etc.) another solution should be found.
And as Jeff pointed out, this should be a central solution and
not be implemented in drivers.

Regards,
Thomas.
