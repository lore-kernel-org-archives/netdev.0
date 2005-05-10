From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 16:36:50 -0700 (PDT)
Message-ID: <20050510.163650.66182323.davem@davemloft.net>
References: <20050510.121214.39158393.davem@davemloft.net>
	<42813205.1040709@hp.com>
	<20050510232132.GZ5495@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: iod00d@hp.com
In-Reply-To: <20050510232132.GZ5495@esmail.cup.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Grant Grundler <iod00d@hp.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 16:21:32 -0700

> HP PCI bus controllers don't disconnect after a cacheline.
> The latest "LBA" (aka Mercury) will disconnect on 4k page
> boundaries. Alex Williamson confirmed.

Ok, good data point.

> Has anyone confirmed PPC, PPC64 and Alpha PCI/PCI-X bus
> controllers do the same?
> 
> ISTR MMRBC (PCI-X only) allows one to specify
> shorter blocks. I'd have to look that up again.

BTW, I just noticed this in the NetBSD tigon3 driver:

#ifdef __brokenalpha__
	/*
	 * Must insure that we do not cross an 8K (bytes) boundary
	 * for DMA reads.  Our highest limit is 1K bytes.  This is a
	 * restriction on some ALPHA platforms with early revision
	 * 21174 PCI chipsets, such as the AlphaPC 164lx
	 */
	PCI_SETBIT(sc, BGE_PCI_DMA_RW_CTL, BGE_PCI_READ_BNDRY_1024, 4);
#endif

This whole DMA boundary issue is turning into a very non-trivial one.

And if it is really true that plain PCI boundary crossing cannot be
controlled on non 5700/5701 chips, the tigon3 is certainly not going
to work reliably on systems such as the Alpha mentioned above.
