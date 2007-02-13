From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [PATCH] fix atl1 braino
Date: Tue, 13 Feb 2007 12:36:51 -0500
Message-ID: <45D1F733.5050205@redhat.com>
References: <20070213071256.GF4095@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751333AbXBMRg7@vger.kernel.org>
In-Reply-To: <20070213071256.GF4095@ftp.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> Spot the bug...
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> 
> diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
> index 08b2d78..e28707a 100644
> --- a/drivers/net/atl1/atl1_hw.c
> +++ b/drivers/net/atl1/atl1_hw.c
> @@ -357,7 +357,7 @@ void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
>  	 */
>  	hash_reg = (hash_value >> 31) & 0x1;
>  	hash_bit = (hash_value >> 26) & 0x1F;
> -	mta = ioread32((hw + REG_RX_HASH_TABLE) + (hash_reg << 2));
> +	mta = ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
>  	mta |= (1 << hash_bit);
>  	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
>  }

The comment above is funny:

349 /*
350 * The HASH Table is a register array of 2 32-bit registers.
351 * It is treated like an array of 64 bits. We want to set
352 * bit BitArray[hash_value]. So we figure out what register
353 * the bit is in, read it, OR in the new bit, then write
354 * back the new value. The register is determined by the
355 * upper 7 bits of the hash value and the bit within that
356 * register are determined by the lower 5 bits of the value.

How can you use seven bits to choose between two registers?
And they're not using the lower 5 bits, but rather bits 30..26.
