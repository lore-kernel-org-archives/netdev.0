From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/12] benet: beclib header files
Date: Thu, 19 Jun 2008 06:29:19 -0400
Message-ID: <20080619102919.GE17697@infradead.org>
References: <20080612104218.0625d526@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56816 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108AbYFSK3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:29:21 -0400
Content-Disposition: inline
In-Reply-To: <20080612104218.0625d526@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/*
> +    Locking structure for beklib.
> +*/
> +struct be_lock {
> +	spinlock_t lock;
> +	unsigned long irql;

Please just use spinlock_t directly.

> +static inline void be_lock_wrb_post(struct be_function_object *pfob)
> +{
> +	spin_lock_irqsave(&pfob->post_lock, pfob->post_irq);
> +}

Please no such locking wrappers.  The flags argument should always be
local to the function calling the locking function and never be stored
in structs, btw.

> +static inline SA_STATUS sa_dev_create(struct sa_dev_bar_locations *bars,
> +		u32 num_bars, void *os_handle, struct sa_dev *dev)
> +{
> +	ASSERT(dev);
> +	ASSERT(bars);
> +
> +	/* Zero the struct */
> +	memset(dev, 0, sizeof(*dev));
> +
> +	/* Copy the bar info */
> +	dev->num_bars = num_bars;
> +	memcpy(dev->bars, bars, sizeof(struct sa_dev_bar_locations) * num_bars);
> +
> +	return SA_SUCCESS;

Just inline this into the caller.

> +}
> +static inline void sa_dev_destroy(struct sa_dev *dev)
> +{
> +	memset(dev, 0, sizeof(*dev));
> +}

Doing a memset on "destroy" is a very bad idea - it'll defeat the slab
posioning feature to find dangling pointers.

> +static inline void sa_dev_stall(struct sa_dev *dev, u32 us_to_stall)
> +{
> +	udelay(us_to_stall);
> +}

Just use udelay directly.

> +    Each .c file in beclib includes this "precompiled header" file.
> +    It should ONLY be included by beclib files.
> +    Clients of beclib should include "beclib.h" instead.
> +*/
> +#ifndef __pch_h__
> +#define __pch_h__
> +
> +/*
> + * -----------------------------------------------------------------------
> + *    Our custom includes
> + * -----------------------------------------------------------------------
> + */
> +
> +#include "beclib_ll.h"
> +#include "beclib_private_ll.h"
> +#include "bestatus.h"

Just use the headers directly where needed.

