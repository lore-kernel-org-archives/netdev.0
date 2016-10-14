From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPv6: Drop the temporary address regen_timer
Date: Fri, 14 Oct 2016 10:59:33 -0400 (EDT)
Message-ID: <20161014.105933.75588707766999077.davem@davemloft.net>
References: <20161013165002.zn7wgjbacs34i73i@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752843AbcJNO7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 10:59:36 -0400
In-Reply-To: <20161013165002.zn7wgjbacs34i73i@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Thu, 13 Oct 2016 18:50:02 +0200

> The randomized interface identifier (rndid) was periodically updated from
> the regen_timer timer. Simplify the code by updating the rndid only when
> needed by ipv6_try_regen_rndid().
> 
> This makes the follow-up DESYNC_FACTOR fix much simpler.  Also it fixes a
> reference counting error in this error path, where an in6_dev_put was
> missing:
> 		err = addrconf_sysctl_register(ndev);
> 		if (err) {
> 			ipv6_mc_destroy_dev(ndev);
> 	-               del_timer(&ndev->regen_timer);
> 			snmp6_unregister_dev(ndev);
> 			goto err_release;
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied.
