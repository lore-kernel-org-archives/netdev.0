From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/8] qlge: Add data for firmware dump.
Date: Mon, 11 Jan 2010 22:20:09 -0800 (PST)
Message-ID: <20100111.222009.30973638.davem@davemloft.net>
References: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
	<1263258785-5112-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48082
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752903Ab0ALGUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 01:20:00 -0500
In-Reply-To: <1263258785-5112-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 11 Jan 2010 17:12:58 -0800

> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge.h |  285 ++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 284 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
> index ee0e2bd..0094263 100644
> --- a/drivers/net/qlge/qlge.h
> +++ b/drivers/net/qlge/qlge.h
> @@ -75,6 +75,16 @@
>  #define TX_DESC_PER_OAL 0
>  #endif
>  
> +/* Word shifting for converting 64-bit
> + * address to a series of 16-bit words.
> + * This is used for some MPI firmware
> + * mailbox commands.
> + */
> +#define LSW(x)  ((u16)(x))
> +#define MSW(x)  ((u16)((u32)(x) >> 16))
> +#define LSD(x)  ((u32)((u64)(x)))
> +#define MSD(x)  ((u32)((((u64)(x)) >> 16) >> 16))

And using plain:

	((u32)(((u64)x) >> 32))

doesn't work for MSD() because?  Shifting right by 16 bits
twice is pointless, and even more importantly confusing.

> +#define MAC_PROTOCOL_REGISTER_WORDS ((512 * 3) + (32 * 2) + (4096 * 1) + \
> +(4096 * 1) + (4 * 2) + (8 * 2) + (16 * 1) + (4 * 1) + (4 * 4) + (4 * 1))

This is poorly formatted and full of magic constants with absolutely
no explanation.

> +/* Save both the address and data register */
> +#define WORDS_PER_MAC_PROT_ENTRY 2
> +#define MAX_SEMAPHORE_FUNCTIONS 5
> +#define WQC_WORD_SIZE 6
> +#define NUMBER_OF_WQCS 128
> +#define CQC_WORD_SIZE 13
> +#define NUMBER_OF_CQCS 128

Poor formatting.

> +#define MPI_READ 0x00000000
> +#define REG_BLOCK 0x00020000
> +#define TEST_LOGIC_FUNC_PORT_CONFIG 0x1002
> +#define NIC1_FUNCTION_ENABLE 0x00000001
> +#define NIC1_FUNCTION_MASK 0x0000000e
> +#define NIC1_FUNCTION_SHIFT 1
> +#define NIC2_FUNCTION_ENABLE 0x00000010
> +#define NIC2_FUNCTION_MASK 0x000000e0
> +#define NIC2_FUNCTION_SHIFT 5
> +#define FC1_FUNCTION_ENABLE 0x00000100
> +#define FC1_FUNCTION_MASK 0x00000e00
> +#define FC1_FUNCTION_SHIFT 9
> +#define FC2_FUNCTION_ENABLE 0x00001000
> +#define FC2_FUNCTION_MASK 0x0000e000
> +#define FC2_FUNCTION_SHIFT 13
> +#define FUNCTION_SHIFT 6

More poor formatting, use tabs to line up the define values
so that it's easier to read by humans (and therefore easier
to spot bugs).

Same goes for the rest of the defines added by this patch.

I'm not even going to look at the rest of this patch series,
please fix up these fundamental code formatting issues,
check for them in the rest of your changes, and resubmit
the whole series.

Thanks.
