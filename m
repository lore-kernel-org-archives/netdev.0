From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] b44 1GB DMA workaround (was: b44: add 47xx support)
Date: Sat, 7 Aug 2004 17:05:03 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040807170503.3b05255a.davem@redhat.com>
References: <200407232335.37809.jolt@tuxbox.org>
	<20040726141128.GA5435@ee.oulu.fi>
	<20040804003108.GA10445@ee.oulu.fi>
	<20040803183919.2990d045.davem@redhat.com>
	<20040807224019.GA24817@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, jolt@tuxbox.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S264881AbUHHAGp@vger.kernel.org>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040807224019.GA24817@ee.oulu.fi>
List-Id: netdev.vger.kernel.org

On Sun, 8 Aug 2004 01:40:19 +0300
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> On Tue, Aug 03, 2004 at 06:39:19PM -0700, David S. Miller wrote:
> > Changing skb->data is not legal.  Please implement this in
> > such a way that skb->data does not get modified.  By modifying
> > skb->data you will break things such as packet sniffers and
> > netfilter, and that's just the tip of the iceberg. :-)
> > 
> Haven't noticed any breakage (tm) but I'm just a x86 weenie :-)

Not an x86 specific problem :-)  Just run tcpdump in a shell when
one of these TX bounce cases happen, your skb->data modification could
will make tcpdump see a corrupt packet.

> Current approach is:
> 
>         if(1 (just for testing ;) ) || mapping+len > B44_DMA_MASK) {
>                 /* Chip can't handle DMA to/from >1GB, use bounce buffer */
>                 pci_unmap_single(bp->pdev, mapping, len,PCI_DMA_TODEVICE);
>                 memcpy(bp->tx_bufs+entry*TX_PKT_BUF_SZ,skb->data,skb->len);
>                 mapping = pci_map_single(bp->pdev,bp->tx_bufs+entry*TX_PKT_BUF_SZ, len, PCI_DMA_TODEVICE);
>         }

This looks a bit better.
