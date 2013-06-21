From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Fri, 21 Jun 2013 12:23:18 +0200
Message-ID: <20130621102318.GA7269@unicorn.suse.cz>
References: <1371746105-2482-7-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41430 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752119Ab3FUKXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 06:23:23 -0400
Content-Disposition: inline
In-Reply-To: <1371746105-2482-7-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 06:35:05PM +0200, Veaceslav Falico wrote:
> @@ -1712,6 +1721,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  
>  	new_slave->last_arp_rx = jiffies -
>  		(msecs_to_jiffies(bond->params.arp_interval) + 1);
> +	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
> +		new_slave->target_last_arp_rx[i] = jiffies;
>  
>  	if (bond->params.miimon && !bond->params.use_carrier) {
>  		link_reporting = bond_check_dev_link(bond, slave_dev, 1);

For cards with slow initial negotiation, this can cause a down -> up ->
down -> up flap on enslaving. This is why initial walue of last_arp_rx
was modified in commit f31c7937. Is there a reason not to initialize
target_last_arp_rx[i] to the same value?

                                                        Michal Kubecek
