From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH v4] qe: miscellaneous code improvements and fixes to the
 QE library
Date: Wed, 3 Oct 2007 09:44:49 -0700
Message-ID: <20071003094449.702c4a90@freepuppy.rosehill>
References: <1191429299378-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org, Timur Tabi <timur@freescale.com>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43829 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751614AbXJCQpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 12:45:18 -0400
In-Reply-To: <1191429299378-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  3 Oct 2007 11:34:59 -0500
Timur Tabi <timur@freescale.com> wrote:

> This patch makes numerous miscellaneous code improvements to the QE library.
> 
> 1. Remove struct ucc_common and merge ucc_init_guemr() into ucc_set_type()
>    (every caller of ucc_init_guemr() also calls ucc_set_type()).  Modify all
>    callers of ucc_set_type() accordingly.
> 
> 2. Remove the unused enum ucc_pram_initial_offset.
> 
> 3. Refactor qe_setbrg(), also implement work-around for errata QE_General4.
> 
> 4. Several printk() calls were missing the terminating \n.
> 
> 5. Add __iomem where needed, and change u16 to __be16 and u32 to __be32 where
>    appropriate.
> 
> 6. In ucc_slow_init() the RBASE and TBASE registers in the PRAM were programmed
>    with the wrong value.
> 
> 7. Add the protocol type to struct us_info and updated ucc_slow_init() to
>    use it, instead of always programming QE_CR_PROTOCOL_UNSPECIFIED.
> 
> 8. Rename ucc_slow_restart_x() to ucc_slow_restart_tx()
> 
> 9. Add several macros in qe.h (mostly for slow UCC support, but also to
>    standardize some naming convention) and remove several unused macros.
> 
> 10. Update ucc_geth.c to use the new macros.
> 
> 11. Add ucc_slow_info.protocol to specify which QE_CR_PROTOCOL_xxx protcol
>     to use when initializing the UCC in ucc_slow_init().
> 
> 12. Rename ucc_slow_pram.rfcr to rbmr and ucc_slow_pram.tfcr to tbmr, since
>     these are the real names of the registers.
> 
> 13. Use the setbits, clrbits, and clrsetbits where appropriate.
> 
> 14. Refactor ucc_set_qe_mux_rxtx().
> 
> 15. Remove all instances of 'volatile'.
> 
> 16. Simplify get_cmxucr_reg();
> 
> 17. Replace qe_mux.cmxucrX with qe_mux.cmxucr[].
> 
> 18. Updated struct ucc_geth because struct ucc_fast is not padded any more.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
> 

Separate the changes into individual patches to allow for better comment/review
and bisection in case of regression.
