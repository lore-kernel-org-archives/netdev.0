From: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 15 Dec 2004 16:03:08 +0100
Message-ID: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>
References: <1103118626.1076.53.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com, Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1103118626.1076.53.camel@jzny.localdomain>
To: hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





jamal <hadi@cyberus.ca> wrote on 15.12.2004 14:50:27:

> When you netif_stop_queue you should never receive packets anymore
> at the device level. If you receive any its a bug and you should drop
> them and bitch violently. In other words i think what you have at the
> moment is bandaid not the solution.

When we do a netif_stop_queue, we do not get any more packets.
So this behaviour is ok. The problem is that the socket write
queues fill up then and get blocked as soon as they are full.

> Can you describe how your driver uses the netif_start/stop/wake
> interfaces?

Before the patch we are talking about:
When we detect a cable pull (or something like this) we call
netif_stop_queue and set switch off the IFF_RUNNING flag.
Then when we detect that the cable is plugged in again, we
call netif_wake_queue and switch the IFF_RUNNING flag on.

And with the patch:
On cable pull we switch off IFF_RUNNING and call
netif_carrier_off. We still get packets but drop them.
When the cable is plugged in we switch on IFF_RUNNING and
call netif_carrier_on.

Regard,
Thomas.
