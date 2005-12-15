From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 21:23:09 -0800 (PST)
Message-ID: <20051214.212309.127095596.davem@davemloft.net>
References: <20051215033937.GC11856@waste.org>
	<20051214.203023.129054759.davem@davemloft.net>
	<20051215050250.GT8637@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, ak@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161125AbVLOFbv@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20051215050250.GT8637@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 14 Dec 2005 21:02:50 -0800

> There needs to be two rules:
> 
> iff global memory critical flag is set
> - allocate from the global critical receive pool on receive
> - return packet to global pool if not destined for a socket with an
>   attached send mempool

This shuts off a router and/or firewall just because iSCSI or NFS peed
in it's pants.  Not really acceptable.

> I think this will provide the desired behavior

It's not desirable.

What if iSCSI is protected by IPSEC, and the key management daemon has
to process a security assosciation expiration and negotiate a new one
in order for iSCSI to further communicate with it's peer when this
memory shortage occurs?  It needs to send packets back and forth with
the remove key management daemon in order to do this, but since you
cut it off with this critical receive pool, the negotiation will never
succeed.

This stuff won't work.  It's not a generic solution and that's
why it has more holes than swiss cheese. :-)
