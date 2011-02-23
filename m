From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 15:08:44 -0800
Message-ID: <20110223230844.GA16476@linuxace.com>
References: <1298490169-5224-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38550 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636Ab1BWXIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 18:08:50 -0500
Received: by yxs7 with SMTP id 7so1517760yxs.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 15:08:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1298490169-5224-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 02:42:49PM -0500, Andy Gospodarek wrote:
> + * destination queue.  Using a helper function skips the a call to

s/the a/a/ or s/the a/the/

> +     while (txq >= dev->real_num_tx_queues) {
> +             /* let the user know if we do not have enough tx queues */
> +             if (net_ratelimit())
> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
> +                                " setting module option tx_queues > %d.",
> +                                dev->name, txq, dev->real_num_tx_queues);
> +             txq -= dev->real_num_tx_queues;
> +     }

Think this would be better as a WARN_ONCE, as otherwise syslog will still
get flooded with this - even when ratelimited.  See get_rps_cpu in 
net/core/dev.c as an example.o

Will test this out.

Phil
