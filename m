From: jamal <hadi@cyberus.ca>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: 21 Sep 2004 07:35:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095766554.1049.49.camel@jzny.localdomain>
References: <52fz5esxx6.fsf@topspin.com>
	 <20040919140133.60ea3fb3.davem@davemloft.net>
	 <1095628759.1049.22.camel@jzny.localdomain>  <52y8j5r1d6.fsf@topspin.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52y8j5r1d6.fsf@topspin.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-20 at 00:49, Roland Dreier wrote:
>     jamal> Probably just easier to have his own private tables holding
>     jamal> reference to neighbor entries instead of polluting the
>     jamal> neighbor tables.  Listens to ARP events - on state
>     jamal> transition to/from reachable state he queries his remote
>     jamal> manager.
> 
> This does seem neater, but I don't know how to implement it.  How does
> one hook into ARP events?

Are you doing the path manager from user space or kernel?
Its easy to generate netlink events to user space; you could then
have the manager create path from user space. 

>     jamal> Curious though if ARP still works even when that "path"
>     jamal> thing hasnt been resolved.
> 
> ARP works because we can send broadcasts even without a path to a
> specific destination.  (I'm leaving out the details of how IP
> broadcast gets mapped to InfiniBand multicast)  When the system with
> the IP we're looking for receives a broadcast ARP, it can use the HW
> address in the ARP request to look up a path, so it can send an ARP
> reply.

So the sending broadcast path is essentially existent already.

Like i said above, depending on how you do this remote manager; in
kernel would be a little more involved.

cheers,
jamal
