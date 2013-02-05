From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v5] netpoll: protect napi_poll and poll_controller during
 dev_[open|close]
Date: Tue, 5 Feb 2013 10:07:13 -0500
Message-ID: <20130205150713.GB4511@hmsreliant.think-freely.org>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
 <1359999644-24872-1-git-send-email-nhorman@tuxdriver.com>
 <20130204.210642.1455120579037699868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ivecera@redhat.com,
	bhutchings@solarflare.com, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36151 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138Ab3BEPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 10:07:25 -0500
Content-Disposition: inline
In-Reply-To: <20130204.210642.1455120579037699868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 04, 2013 at 09:06:42PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon,  4 Feb 2013 12:40:44 -0500
> 
> > +	/*
> > +	 * Block netpoll from trying to do any rx path servicing.
> > +	 * If we don't do this there is a chance ndo_poll_controller
> > +	 * or ndo_poll may be running while we open the device
> > +	 */
> 
> Please format comments:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> > +	/*
> > +	 * Don't do any rx activity if the dev_lock mutex is held 
> > +	 * the dev_open/close paths use this to block netpoll activity
> > +	 * while changing device state
> > +	 */
> 
> Same here.
> 
> > +int netpoll_rx_disable(struct net_device *dev)
> > +{
> > +        struct netpoll_info *ni;
> > +	int idx;
> > +        might_sleep();
> > +        idx = srcu_read_lock(&netpoll_srcu);
> > +        ni = srcu_dereference(dev->npinfo, &netpoll_srcu);
> 
> A lot of interesting indentation going on here.
Apologies, Dave, I rushed and forgot to run checkpatch.  I'll resend shortly.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
