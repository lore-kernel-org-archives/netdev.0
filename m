From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 12:12:14 -0700 (PDT)
Message-ID: <20050510.121214.39158393.davem@davemloft.net>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
	<1115743966.8570.26.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1115743966.8570.26.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 09:52:46 -0700

> In the new code, the DMA write bursts will disconnect at multiples of
> cache lines instead of 1 cache line. And DMA read bursts will not
> disconnect at cache line boundaries.

We really should be disconnecting at single cacheline boundaries
on RISC systems.  The PCI controllers on RISC machines are
going to disconnect the tg3 when it crosses a cache line
boundary, so all these setting do is waste PCI bandwidth.

>From the sparc64 PCI controller programmer's manual:

"When a DMA burst transfer attempts to go past a cache line (64B)
 boundary, U2P generates a disconnect.  This should cause the
 master device to attempt the transaction again beginning at the
 address of the next untransferred data."

Most other RISC systems have PCI controllers which
behave similarly if not identically, although there
are probably some exceptions.

Anyways, it is clear this code needs to change. :-)
