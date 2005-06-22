From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 23:10:58 +0200
Message-ID: <20050622211058.GY14251@wotan.suse.de>
References: <1119458226.6918.142.camel@localhost.localdomain> <200506221801.j5MI11xS021866@guinness.s2io.com> <20050622180654.GX14251@wotan.suse.de> <20050622.132241.21929037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, leonid.grossman@neterion.com, hadi@cyberus.ca,
        becker@scyld.com, rick.jones2@hp.com, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050622.132241.21929037.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2005 at 01:22:41PM -0700, David S. Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Wed, 22 Jun 2005 20:06:55 +0200
> 
> > However it is tricky because CPUs have only a limited load queue
> > entries and doing too many prefetches will just overflow that.
> 
> Several processors can queue about 8 prefetch requests, and
> these slots are independant of those consumed by a load.

8 entries? That sounds very small. Is that an old Sparc or something? :)

An Opteron has 44 entries, effectively 32 for L2.   Netburst
or POWER4 derived CPUs have more than that.

> Yes, if you queue too many prefetches, the queue overflows.
> 
> I think the optimal scheme would be:
> 
> 1) eth_type_trans() info in RX descriptor
> 2) prefetch(skb->data) done as early as possible in driver
>    RX handling
> 
> Actually, I believe to most optimal scheme is:

Looks reasonable. Not sure about the "most optimal" though, some benchmarking
of different schemes would be probably a good idea.

-Andi
