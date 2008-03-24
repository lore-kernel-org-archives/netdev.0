From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] New driver "sfc" for Solarstorm SFC4000 controller
 (try #8)
Date: Sun, 23 Mar 2008 22:38:41 -0700 (PDT)
Message-ID: <20080323.223841.235095904.davem@davemloft.net>
References: <20080312012102.GB24160@solarflare.com>
	<20080312012513.GG24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbYCXFim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:38:42 -0400
In-Reply-To: <20080312012513.GG24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Mar 2008 01:25:14 +0000

> +/* Writes to a normal 16-byte Falcon register, locking as appropriate. */
> +static inline void falcon_write(struct efx_nic *efx, efx_oword_t *value,
> +				unsigned int reg)
> +{
> +	unsigned long flags __attribute__ ((unused));

Delete.

> +/* Writes to an 8-byte Falcon SRAM register, locking as appropriate. */
> +static inline void falcon_write_sram(struct efx_nic *efx, efx_qword_t *value,
> +				     unsigned int index)
> +{
> +	unsigned int reg = efx->type->buf_tbl_base + (index * sizeof(*value));
> +	unsigned long flags __attribute__ ((unused));

Delete.

> +/* Read from a Falcon register
> + *
> + * This reads an entire 16-byte Falcon register in one go, locking as
> + * appropriate.  It is essential to read the first dword first, as this
> + * prompts Falcon to load the current value into the shadow register.
> + */
> +static inline void falcon_read(struct efx_nic *efx, efx_oword_t *value,
> +			       unsigned int reg)
> +{
> +	unsigned long flags __attribute__ ((unused));

Delete.

> +static inline void falcon_read_sram(struct efx_nic *efx, efx_qword_t *value,
> +				    unsigned int index)
> +{
> +	unsigned int reg = efx->type->buf_tbl_base + (index * sizeof(*value));
> +	unsigned long flags __attribute__ ((unused));

Delete.

> +/* Write dword to Falcon page-mapped register with an extra lock.
> + *
> + * As for falcon_writel_page(), but for a register that suffers from
> + * SFC bug 3181. Take out a lock so the BIU collector cannot be
> + * confused. */
> +static inline void falcon_writel_page_locked(struct efx_nic *efx,
> +					     efx_dword_t *value,
> +					     unsigned int reg,
> +					     unsigned int page)
> +{
> +	unsigned long flags __attribute__ ((unused));

Remove the unused tag, it's wrong.
