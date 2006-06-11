From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] [patch 2/6] [Network namespace] Network device sharing by
 view
Date: Sun, 11 Jun 2006 03:18:59 -0700
Message-ID: <20060611031859.eed22867.akpm@osdl.org>
References: <20060609210202.215291000@localhost.localdomain>
	<20060609210625.144158000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10637 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751574AbWFKKTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 06:19:21 -0400
To: dlezcano@fr.ibm.com
In-Reply-To: <20060609210625.144158000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 09 Jun 2006 23:02:04 +0200
dlezcano@fr.ibm.com wrote:

> +int net_ns_dev_add(const char *devname,
> +		   struct net_ns_dev_list *devlist)
> +{
> +	struct net_ns_dev *db;
> +	struct net_device *dev;
> +	int ret = 0;
> +
> +	read_lock(&dev_base_lock);
> +
> +	for (dev = dev_base; dev; dev = dev->next)
> +		if (!strncmp(dev->name, devname, IFNAMSIZ))
> +			break;
> +
> +	if (!dev) {
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +	db = kmalloc(sizeof(*db), GFP_KERNEL);

sleep-in-spinlock.  Please always test new code with all kernel debugging
options enabled.
