From: "David S. Miller" <davem@redhat.com>
Subject: Re: NAPI for eepro100
Date: Thu, 13 Jun 2002 01:47:00 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae9mlg$n5l$2@main.gmane.org>
References: <3D07D270.5060902@mandrakesoft.com>
	<20020612.160532.134201977.davem@redhat.com>
	<20020613125753.A23693@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fxzhang@ict.ac.cn, linux-mips@oss.sgi.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, jgarzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: saw@saw.sw.com.sg
In-Reply-To: <20020613125753.A23693@castle.nmd.msu.ru>
List-Id: netdev.vger.kernel.org

   From: Andrey Savochkin <saw@saw.sw.com.sg>
   Date: Thu, 13 Jun 2002 12:57:53 +0400

   On Wed, Jun 12, 2002 at 04:05:32PM -0700, David S. Miller wrote:
   > No, it's worse than that.
   > 
   > See how non-consistent memory is used by the eepro100 driver
   > for descriptor bits?  The skb->tail bits?
   > 
   > That is very problematic.
   
   What's the problem?
   If it isn't allowed to do, then what is the meaning of PCI_DMA_BIDIRECTIONAL
   mappings?

It's slow.  Not wrong, just inefficient.

Descriptors were meant to be done using consistent mappings, not
"pci_map_*()"'d memory.  The latter is meant to be used for long
linear DMA transfers to/from the device.  It is not meant for things
the cpu pokes small bits of data in and out of, that is what
consistent DMA memory is for.
