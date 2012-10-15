From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv5 1/4] modem_shm: Add Modem Access Framework
Date: Mon, 15 Oct 2012 14:29:43 -0700
Message-ID: <20121015212943.GA12540@kroah.com>
References: <1350278920-25510-1-git-send-email-arun.murthy@stericsson.com>
 <1350278920-25510-2-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Arun Murthy <arun.murthy@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1350278920-25510-2-git-send-email-arun.murthy@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2012 at 10:58:37AM +0530, Arun Murthy wrote:

I'm going to ignore your .c logic, as there are things in it that I
don't think is correct.  But it all comes down to your data structures,
if you fix them, then the .c logic will become correct:

> --- /dev/null
> +++ b/include/linux/modem_shm/modem.h
> @@ -0,0 +1,59 @@
> +/*
> + * Copyright (C) ST-Ericsson SA 2011
> + *
> + * License Terms: GNU General Public License v2
> + * Author: Kumar Sanghvi
> + *	Arun Murthy <arun.murthy@stericsson.com>
> + *
> + * Heavily adapted from Regulator framework
> + */
> +#ifndef __MODEM_H__
> +#define __MODEM_H__

__MODEM_SHM_MODEM_H__, right?

> +
> +#include <linux/device.h>
> +
> +struct clients {
> +	struct device *dev;

Why is this a pointer?  It should be embedded in the structure.

> +	const char *name;

Why is this needed?  It should be the same as the device, right?

> +	atomic_t cnt;

Why is this needed at all?  And if it's needed, why is it an atomic?
(hint, your use of atomic_t really isn't correct at all in this patch,
it's not doing what you think it is doing...)

> +};

Also, the name of the structure here is _VERY_ generic, that's not
acceptable in the global kernel namespace.  Hint, it probably isn't even
needed to be defined in this .h file at all, right?

> +
> +struct modem_desc {
> +	int (*request)(struct modem_desc *);
> +	void (*release)(struct modem_desc *);
> +	int (*is_requested)(struct modem_desc *);
> +	struct clients *mclients;

Why do you have a pointer to a device, and yet:

> +	struct device *dev;

have a device here?

> +	char *name;

Same *dev and name comment as above.

> +	u8 no_clients;
> +	atomic_t use_cnt;
> +	atomic_t cli_cnt;

Same question about these atomic_t variables, why are they here, and
most importantly, why are they an atomic variable?

thanks,

greg k-h
