From: jamal <hadi@cyberus.ca>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: 19 Sep 2004 17:19:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095628759.1049.22.camel@jzny.localdomain>
References: <52fz5esxx6.fsf@topspin.com>
	 <20040919140133.60ea3fb3.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040919140133.60ea3fb3.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-09-19 at 17:01, David S. Miller wrote:
> You probably want to be editing net/ipv4/arp.c and testing
> it about Infiniband.  Keep neighbour entries in the unresolved
> stated until both transitions are made:
> 
> 1) obtain 20 byte address
> 2) get response from IB subnet manager
> 
> Only store the destination GID in the neighbour entry,
> and only mark the neighbour entry as resolved once
> #2 above completes successfully.

Probably just easier to have his own private tables holding reference to
neighbor entries instead of polluting the neighbor tables.
Listens to ARP events - on state transition to/from reachable state he
queries his remote manager. 
Curious though if ARP still works even when that "path" thing hasnt been
resolved.

cheers,
jamal
