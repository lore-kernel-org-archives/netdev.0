From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH 1/2 net-next][v2] bonding: fix incorrect transmit queue
 offset
Date: Tue, 1 Mar 2011 17:40:09 -0800
Message-ID: <20110302014009.GA2045@linuxace.com>
References: <20110223230844.GA16476@linuxace.com>
 <20110223.151357.245408084.davem@davemloft.net>
 <1298504269.2211.503.camel@localhost>
 <20110223.155451.70202591.davem@davemloft.net>
 <20110225225636.GA18792@linuxace.com>
 <20110301153135.GL11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:65314 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab1CBBkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 20:40:18 -0500
Received: by pxi15 with SMTP id 15so902582pxi.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 17:40:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110301153135.GL11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 10:31:36AM -0500, Andy Gospodarek wrote:
> > The patch works as expected.  Do we have any agreement on a final version?
> >
>
> Thanks for the testing, Phil.
>
> I'm in favor of this patch as it does alert the admin that bonding may
> not have enough default queues, but it is not as verbose (backtrace et
> al) and likely to create bug reports as a message from WARN_ON.
> +             if (net_ratelimit())
> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
> +                                " setting module option tx_queues > %d.",
> +                                dev->name, txq, dev->real_num_tx_queues);

It is unclear why we need to alert the admin to this situation (repeatedly).  
Say the incoming nic has 32 queues, and is headed out a bond (with 16).
With your patch, we will log 50% of the time, no?  What benefit is this
log spew?

While WARN_ONCE may be a bit extreme due to the backtrace, perhaps we
should at least throw a 'static bool warned' variable in there to lessen
the nuisance?

Phil
