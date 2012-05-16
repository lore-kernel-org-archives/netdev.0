From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: convert to modular building
Date: Wed, 16 May 2012 11:16:15 -0400
Message-ID: <20120516151615.GA30195@hmsreliant.think-freely.org>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
 <1337179681.8512.1212.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48647 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab2EPPQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 11:16:22 -0400
Content-Disposition: inline
In-Reply-To: <1337179681.8512.1212.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 16, 2012 at 04:48:01PM +0200, Eric Dumazet wrote:
> On Wed, 2012-05-16 at 10:27 -0400, Neil Horman wrote:
> > When I first wrote drop monitor I wrote it to just build monolithically.  There
> > is no reason it can't be built modularly as well, so lets give it that
> > flexibiity.
> 
> > +	for_each_present_cpu(cpu) {
> > +		data = &per_cpu(dm_cpu_data, cpu);
> > +		del_timer(&data->send_timer);
> > +		cancel_work_sync(&data->dm_alert_work);
> > +		/*
> > +		 * At this point, we should have exclusive access
> > +		 * to this struct and can free the skb inside it
> > +		 */
> > +		kfree_skb(data->skb);
> > +	}
> > +
> 
> I dont think for_each_present_cpu(cpu) is right 
> 
> (I realize drop_monitor already uses this, but its a bug)
> 
> To use it, you must have a notifier to react to cpu HOTPLUG events.
> 
> -> for_each_possible_cpu() is more correct.
> 
Ok, i can do that.
> Also, please dont add new printk(KERN_WARNING ...), use pr_warn(...)
> instead
> 
Ack, I'll add a patch to this series to convert the existing printks to their
corresponding pr_* macros
Neil

> 
> 
> 
