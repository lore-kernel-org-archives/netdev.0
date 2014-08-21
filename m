From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/8] staging: et131x: Use for loop to initialise
 contiguous macstat registers to zero
Date: Thu, 21 Aug 2014 08:40:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1747D483@AcuExch.aculab.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
 <1408573078-9320-5-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Mark Einon' <mark.einon@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408573078-9320-5-git-send-email-mark.einon@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Einon
> Replace a long list of contiguous writel() calls with a for loop iterating
> over the same address values.
> 
> Also remove redundant comments on the macstat registers, the variable names
> are good enough.
...
> -	writel(0, &macstat->txrx_0_64_byte_frames);
...
> -	writel(0, &macstat->carry_reg2);
> +	/* initialize all the macstat registers to zero on the device  */
> +	for (reg = &macstat->txrx_0_64_byte_frames;
> +	     reg <= &macstat->carry_reg2; reg++)
> +		writel(0, reg);
...
>  struct macstat_regs {			/* Location: */
>  	u32 pad[32];			/*  0x6000 - 607C */
> 
> -	/* Tx/Rx 0-64 Byte Frame Counter */
> +	/* counters */
>  	u32 txrx_0_64_byte_frames;	/*  0x6080 */
> -
> -	/* Tx/Rx 65-127 Byte Frame Counter */
>  	u32 txrx_65_127_byte_frames;	/*  0x6084 */

I think it would be best to also convert the stats counters to an array.

	David
