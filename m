From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] bonding: start slaves with link down for ARP monitor
Date: Sat, 14 Apr 2012 21:09:29 +0200
Message-ID: <20120414190929.GA8424@lion.mk-sys.cz>
References: <94e5ccf29d92f9a4b815f895b6bb8d9f326566cb.1334256203.git.mkubecek@suse.cz>
 <20120414015319.11e196d4@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kubecekserver.ph.gin.cz ([212.71.128.105]:56318 "EHLO
	kubecekserver.ph.gin.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2DNTJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:09:45 -0400
Content-Disposition: inline
In-Reply-To: <20120414015319.11e196d4@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 14, 2012 at 01:53:19AM -0300, Flavio Leitner wrote:
> On Thu, 12 Apr 2012 20:38:09 +0200
> Michal Kubecek <mkubecek@suse.cz> wrote:
> >  	new_slave->last_arp_rx = jiffies;
> > +	if (bond->params.arp_interval)
> > +		new_slave->last_arp_rx -=
> > +			(msecs_to_jiffies(bond->params.arp_interval) + 1);
> 
> 
> I don't see the point of checking bond->params.arp_interval.
> Why not simply:
> 
> - 	new_slave->last_arp_rx = jiffies;
> +	/* put it behind to avoid fake initial link up detection */
> +	new_slave->last_arp_rx = jiffies -
> +		 (msecs_to_jiffies(bond->params.arp_interval) + 1);

The idea was to avoid calculation when ARP monitoring is off. But
thinking it over again, this part of the code is not that performance
critical and the conditional jump may be in fact worse than the two
instructions it would jump over.

                                                       Michal Kubecek
