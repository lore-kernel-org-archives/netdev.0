From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 06 Dec 2004 21:22:55 -0500
Message-ID: <1102386174.1093.21.camel@jzny.localdomain>
References: <E1CbTv3-000732-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, paul@clubi.ie, thomas.spatzier@de.ibm.com,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CbTv3-000732-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, 2004-12-06 at 20:13, Herbert Xu wrote:
> Hasso Tepper <hasso@estpak.ee> wrote:
> > 
> > Seems that it's no longer true. Seems that kernel is now trying as hard as 
> > possible not to loose any data - data is queued and if the queue will be 
> > full, all related sockets will be blocked to notify application. So, one 
> > socket approach don't work any more for Quagga/Zebra. No problem, we can 
> > take the "one socket per interface" approach. And we already have link 
> > detection implemented to notify daemons.
> 
> I don't see why this should be happening.  Can you please provide a
> minimal program that reproduces this blocking problem? For example,
> something that sends a packet to a downed interface and then sends
> one to an interface that's up?

This may be something to do with socket level changes maybe?
Does this happen with sockets that are not raw?

Having said that: I think getting rid of obsolete messages is important.
One of the suggested schemes of operation sounds to be the least brutal.

Jgarzik, I thought about it a little and it seems to me that allowing
the device driver to drop packets on txmit when netcarrier is off is not
that bad. This is almost like pretending packets were dropped on the
wire. Thoughts?

cheers,
jamal 
