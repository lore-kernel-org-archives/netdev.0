From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Sun, 19 Sep 2004 21:49:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <52y8j5r1d6.fsf@topspin.com>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
	<1095628759.1049.22.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095628759.1049.22.camel@jzny.localdomain> (jamal's message of
 "19 Sep 2004 17:19:19 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    jamal> Probably just easier to have his own private tables holding
    jamal> reference to neighbor entries instead of polluting the
    jamal> neighbor tables.  Listens to ARP events - on state
    jamal> transition to/from reachable state he queries his remote
    jamal> manager.

This does seem neater, but I don't know how to implement it.  How does
one hook into ARP events?

    jamal> Curious though if ARP still works even when that "path"
    jamal> thing hasnt been resolved.

ARP works because we can send broadcasts even without a path to a
specific destination.  (I'm leaving out the details of how IP
broadcast gets mapped to InfiniBand multicast)  When the system with
the IP we're looking for receives a broadcast ARP, it can use the HW
address in the ARP request to look up a path, so it can send an ARP
reply.

Thanks,
  Roland
