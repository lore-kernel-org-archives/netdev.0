From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] Unaligned accesses in the ethernet bridge
Date: Thu, 6 Apr 2006 22:37:08 +0200
Message-ID: <20060406203708.GA7118@stusta.de>
References: <17442.650.874609.271109@berry.ken.nicta.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751312AbWDFUhN@vger.kernel.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Content-Disposition: inline
In-Reply-To: <17442.650.874609.271109@berry.ken.nicta.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2006 at 01:06:02PM +1100, Peter Chubb wrote:
> 
> I see lots of
> 	kernel unaligned access to 0xa0000001009dbb6f, ip=0xa000000100811591
> 	kernel unaligned access to 0xa0000001009dbb6b, ip=0xa0000001008115c1
> 	kernel unaligned access to 0xa0000001009dbb6d, ip=0xa0000001008115f1
> messages in my logs on IA64 when using the ethernet bridge with 2.6.16.
> 
> 
> Appended is a patch to fix them.


I see this patch already made it into 2.6.17-rc1.

It seems to be a candidate for 2.6.16.3, too?
If yes, please submit it to stable@kernel.org.


> Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
> 
> 
>  net/bridge/br_stp_bpdu.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6-import/net/bridge/br_stp_bpdu.c
> ===================================================================
> --- linux-2.6-import.orig/net/bridge/br_stp_bpdu.c	2006-03-22 09:11:01.349886375 +1100
> +++ linux-2.6-import/net/bridge/br_stp_bpdu.c	2006-03-23 12:52:13.719239205 +1100
> @@ -19,6 +19,7 @@
>  #include <linux/llc.h>
>  #include <net/llc.h>
>  #include <net/llc_pdu.h>
> +#include <asm/unaligned.h>
>  
>  #include "br_private.h"
>  #include "br_private_stp.h"
> @@ -59,12 +60,12 @@ static inline void br_set_ticks(unsigned
>  {
>  	unsigned long ticks = (STP_HZ * j)/ HZ;
>  
> -	*((__be16 *) dest) = htons(ticks);
> +	put_unaligned(htons(ticks), (__be16 *)dest);
>  }
>  
>  static inline int br_get_ticks(const unsigned char *src)
>  {
> -	unsigned long ticks = ntohs(*(__be16 *)src);
> +	unsigned long ticks = ntohs(get_unaligned((__be16 *)src));
>  
>  	return (ticks * HZ + STP_HZ - 1) / STP_HZ;
>  }

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
