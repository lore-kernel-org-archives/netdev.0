From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 02/27] HFI: Add HFI adapter control structure
Date: Wed, 2 Mar 2011 14:21:26 -0800
Message-ID: <20110302142126.193a8817@nehalam>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	<1299100213-8770-2-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52642 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab1CBWVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 17:21:31 -0500
In-Reply-To: <1299100213-8770-2-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Mar 2011 16:09:48 -0500
dykmanj@linux.vnet.ibm.com wrote:

> diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
> index 80790c6..6fe4e60 100644
> --- a/drivers/net/hfi/core/Makefile
> +++ b/drivers/net/hfi/core/Makefile
> @@ -1,5 +1,6 @@
>  #
>  # Makefile for the HFI device driver for IBM eServer System p
>  #
> -hfi_core-objs:=	hfidd_init.o
> +hfi_core-objs:=	hfidd_adpt.o \
> +		hfidd_init.o
>  obj-$(CONFIG_HFI) += hfi_core.o
> diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
> new file mode 100644
> index 0000000..d64fa38
> --- /dev/null
> +++ b/drivers/net/hfi/core/hfidd_adpt.c
> @@ -0,0 +1,60 @@
> +/*
> + * hfidd_adpt.c
> + *
> + * HFI device driver for IBM System p
> + *
> + *  Authors:
> + *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
> + *      William S. Cadden <wscadden@linux.vnet.ibm.com>
> + *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
> + *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
> + *      Jian Xiao <jian@linux.vnet.ibm.com>
> + *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
> + *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
> + *
> + *  (C) Copyright IBM Corp. 2010
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + *
> + */
> +
> +#include <linux/hfi/hfidd_internal.h>
> +#include "hfidd_proto.h"
> +
> +int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
> +{
> +
> +	struct hfidd_acs	*p_acs = NULL;
> +
> +	p_acs = kzalloc(sizeof(*p_acs), GFP_KERNEL);
> +	if (p_acs == NULL)
> +		return -ENOMEM;
> +
> +	p_acs->dev_num = devno;
> +	p_acs->index  = MINOR(devno);
> +	p_acs->state  = HFI_INVALID;
> +	snprintf(p_acs->name, HFI_DEVICE_NAME_MAX - 1,
> +			"%s%d", HFIDD_DEV_NAME, p_acs->index);
> +
> +	*adpt = p_acs;
> +	return 0;
> +}
> +
> +void hfidd_free_adapter(struct hfidd_acs *p_acs)
> +{
> +	kfree(p_acs);
> +	p_acs = NULL;
> +	return;
> +}

If these were not in a separate file the could be marked as static.

Doing a return; on last line of a void function is considered poor
style since it is unnecessary.

-- 
