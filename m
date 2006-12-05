From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Tue, 5 Dec 2006 10:32:39 +0000
Message-ID: <20061205103239.GA10312@infradead.org>
References: <200612031936.34343.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Torokhov <dtor@insightbb.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44991 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937423AbWLEKco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:32:44 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200612031936.34343.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/*
> + * Function called by the key driver when the rfkill structure
> + * needs to be registered.
> + */
> +int rfkill_register_key(struct rfkill *rfkill, int init_status)
> +{
> +	struct rfkill_type *type = &master->type[rfkill->key_type];
> +	struct rfkill_key *key;
> +	int status;
> +
> +	if (!rfkill)
> +		return -EINVAL;	
> +
> +	if (rfkill->key_type >= KEY_TYPE_MAX)
> +		return -EINVAL;
> +
> +	/*
> +	 * Increase module use count to prevent this
> +	 * module to be unloaded while there are still
> +	 * registered keys.
> +	 */
> +	if (!try_module_get(THIS_MODULE))
> +		return -EBUSY;

This is obviously broken.  Please add a "struct module *owner;"
field to struct rfkill instead.

