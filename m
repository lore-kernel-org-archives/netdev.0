From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: fix user-controlled queuing
	issues
Date: Tue, 22 Feb 2011 11:19:41 -0500
Message-ID: <20110222161941.GE11864@gospo.rdu.redhat.com>
References: <1298328783-10073-1-git-send-email-andy@greyhouse.net> <20110222155518.GA14991@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753589Ab1BVQVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 11:21:03 -0500
Content-Disposition: inline
In-Reply-To: <20110222155518.GA14991@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 22, 2011 at 07:55:18AM -0800, Phil Oester wrote:
> On Mon, Feb 21, 2011 at 05:53:03PM -0500, Andy Gospodarek wrote:
> > Users noticed the following messages were filling their logs when using
> > queue 16 for user-mode bonding:
> > 
> > kernel: bond0 selects TX queue 16, but real number of TX queues is 16
> > 
> > ---
> > 
> > My tests all seem to work well, but more testing/feedback is obviously
> > appreciated.
> 
> Sorry, this patch does not fix the issue:
> 
> Feb 22 10:46:50 foo kernel: bond0 selects TX queue 16, but real number of TX queues is 16
> 
> Adding the below debugging patch confirms:
> 
> --- a/net/core/dev.c.orig       2011-02-17 11:42:09.110280300 -0500
> +++ b/net/core/dev.c    2011-02-17 11:40:42.110280300 -0500
> @@ -2060,6 +2060,11 @@
>         int queue_index;
>         const struct net_device_ops *ops = dev->netdev_ops;
>  
> +                if (net_ratelimit()) {
> +                        pr_warning("dev_pick_tx: %s queue_mapping=%d, real_num=%d\n",
> +                                dev->name, skb->queue_mapping, dev->real_num_tx_queues);
> +                }
> +
>         if (ops->ndo_select_queue) {
>                 queue_index = ops->ndo_select_queue(dev, skb);
>                 queue_index = dev_cap_txqueue(dev, queue_index);
> 
> 
> Produces a number of these in the logs:
> 
> Feb 22 10:46:50 foo kernel: dev_pick_tx: bond0 queue_mapping=16, real_num=16
> 

Phil,

Can you send me the minimal set of tc rules that selects output queue 16
and the output of /proc/net/bonding/bond0?

Private email is fine if you do not want to post it to the list.

Thanks,

-andy

