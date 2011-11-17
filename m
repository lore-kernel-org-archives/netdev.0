From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/2] net: add network priority cgroup infrastructure
Date: Thu, 17 Nov 2011 09:29:24 +0000 (UTC)
Message-ID: <ja2k5j$hca$1@dough.gmane.org>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
	<1321476666-8225-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:54410 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab1KQJ3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 04:29:40 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RQyHq-0002ru-I9
	for netdev@vger.kernel.org; Thu, 17 Nov 2011 10:29:38 +0100
Received: from 180.129.255.73 ([180.129.255.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 10:29:38 +0100
Received: from xiyou.wangcong by 180.129.255.73 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 10:29:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2011 15:51:05 -0500, Neil Horman wrote:
 
> +static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	struct cgroup_netprio_state *cs;
> +	struct net_device *dev;
> +
> +	cs = cgrp_netprio_state(cgrp);
> +	rtnl_lock();
> +	for_each_netdev(&init_net, dev) {
> +		if (dev->priomap)
> +			dev->priomap->priomap[cs->prioidx] = 0; 
> +	}
> +	rtnl_unlock();
> +	put_prioidx(cs->prioidx);
> +out_free:
> +	kfree(cs);
> +}

'out_free' is unused.


> +
> +static int write_priomap(struct cgroup *cgrp, struct cftype *cft, 
> +			 const char *buffer)
> +{
> +	char *devname = kstrdup(buffer, GFP_KERNEL); 
> +	int ret = -EINVAL;
> +	u32 prioidx = cgrp_netprio_state(cgrp)->prioidx; 
> +	unsigned long priority;
> +	char *priostr;
> +	struct net_device *dev;
> +
> +	devname = kstrdup(buffer, GFP_KERNEL); 


kstrdup() is called twice...


Thanks.
