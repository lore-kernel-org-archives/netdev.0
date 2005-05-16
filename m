From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Interdomain/interpartition communication without a checksum
Date: Mon, 16 May 2005 13:07:37 -0700 (PDT)
Message-ID: <20050516.130737.77060495.davem@davemloft.net>
References: <20050511183554.GA28298@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, niv@us.ibm.com, habanero@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <20050511183554.GA28298@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Wed, 11 May 2005 13:35:54 -0500

> I have been working on a Xen project to remove unnecessary TCP/UDP
> checksums for local (interdomain) communication, while still having the
> checksum for all external network communication.  

I have no objections to this idea.  But let's think about
the implementation.

> +	/* If packet is forwarded to a device that needs a checksum and not 
> +	 * checksummed, correct the pointers and enable checksumming in the 
> +	 * next function.
> +	 */
> +	if (!(dev->features & NETIF_F_FWD_NO_CSUM) && skb->csum) {
> +		skb->ip_summed = CHECKSUM_HW;
> +		skb->h.raw = (void *)skb->nh.iph + (skb->nh.iph->ihl * 4);
> +	}
> +

This means that every packet which the networking tries to checksum
offload will pass this test, superfluously doing these assignments.

It also assumes ipv4.  ipv6 is possible, and for NETIF_F_CHECKSUM_HW
any protocol could be creating the packets as this flag indicates
that the card implements a totally generic 16-bit two's complement
checksum.
