From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 2/5] S2IO: Fixes for reset and link handling.
Date: Tue, 23 Jan 2007 00:45:22 -0500
Message-ID: <45B5A0F2.5040108@garzik.org>
References: <Pine.GSO.4.10.10701190231190.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	sriram.rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45346 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933007AbXAWFpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:45:24 -0500
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10701190231190.22012-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> 1. Fix for reset and link handling.
> 2. Allow for promiscuos mode and multicast state be maintained through
>    ifconfig up and down.
> 3. Support to print adapter serial number.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

overall, looks OK, but have small nits noted inline:


> +	/*
> +	 * Andrew: in PCI 33 mode, the P_PLL is not used, and therefore,
> +	 * the the P_PLL_LOCK bit in the adapter_status register will
> +	 * not be asserted.
> +	 */

don't address somebody in a code comment ("Andrew:")



> @@ -537,9 +539,9 @@ typedef struct _RxD_block {
>  
>  #define SIZE_OF_BLOCK	4096
>  
> -#define RXD_MODE_1	0
> -#define RXD_MODE_3A	1
> -#define RXD_MODE_3B	2
> +#define RXD_MODE_1	0 //One Buffer mode
> +#define RXD_MODE_3A	1 //Three Buffer mode
> +#define RXD_MODE_3B	2 //Two Buffer mode

C++ comments discouraged


> @@ -849,8 +851,9 @@ struct s2io_nic {
>  	spinlock_t	rx_lock;
>  	atomic_t	isr_cnt;
>  	u64 *ufo_in_band_v;
> -#define VPD_PRODUCT_NAME_LEN 50
> -	u8  product_name[VPD_PRODUCT_NAME_LEN];
> +#define VPD_STRING_LEN 80
> +	u8  product_name[VPD_STRING_LEN];
> +	u8  serial_num[VPD_STRING_LEN];
>  };
>  
>  #define RESET_ERROR 1;
> @@ -893,10 +896,10 @@ static inline void SPECIAL_REG_WRITE(u64
>  		writel((u32) (val), addr);
>  		ret = readl(addr);
>  		writel((u32) (val >> 32), (addr + 4));
> -		ret = readl(addr + 4);
> +		ret = readl((addr + 4));
>  	} else {
>  		writel((u32) (val >> 32), (addr + 4));
> -		ret = readl(addr + 4);
> +		ret = readl((addr + 4));
>  		writel((u32) (val), addr);
>  		ret = readl(addr);
>  	}

adds pointless parens


