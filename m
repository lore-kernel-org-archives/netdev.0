From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 31 Jan 2017 12:18:45 +1100
Message-ID: <20170131121845.759053d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Rafal Ozieblo <rafalo@cadence.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/cadence/macb.h

between commit:

  dc97a89e726c ("net: macb: Fix 64 bit addressing support for GEM")

from the net tree and commit:

  c2594d804d5c ("macb: Common code to enable ptp support for MACB/GEM")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/cadence/macb.h
index fc8550a5d47f,94ddedd2d83e..000000000000
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@@ -385,9 -426,18 +426,20 @@@
  /* Bitfields in DCFG6. */
  #define GEM_PBUF_LSO_OFFSET			27
  #define GEM_PBUF_LSO_SIZE			1
 +#define GEM_DAW64_OFFSET			23
 +#define GEM_DAW64_SIZE				1
  
+ /* Bitfields in TISUBN */
+ #define GEM_SUBNSINCR_OFFSET			0
+ #define GEM_SUBNSINCR_SIZE			16
+ 
+ /* Bitfields in TI */
+ #define GEM_NSINCR_OFFSET			0
+ #define GEM_NSINCR_SIZE				8
+ 
+ /* Bitfields in ADJ */
+ #define GEM_ADDSUB_OFFSET			31
+ #define GEM_ADDSUB_SIZE				1
  /* Constants for CLK */
  #define MACB_CLK_DIV8				0
  #define MACB_CLK_DIV16				1
@@@ -885,9 -942,7 +952,11 @@@ struct macb 
  
  	u32			wol;
  
 +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 +	enum macb_hw_dma_cap hw_dma_cap;
 +#endif
++
+ 	struct macb_ptp_info	*ptp_info;	/* macb-ptp interface */
  };
  
  static inline bool macb_is_gem(struct macb *bp)
