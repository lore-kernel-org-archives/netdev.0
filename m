From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [RFC] [patch 2/6] [Network namespace] Network device sharing by view
Date: Sun, 18 Jun 2006 19:53:06 +0100
Message-ID: <20060618185306.GC27946@ftp.linux.org.uk>
References: <20060609210202.215291000@localhost.localdomain> <20060609210625.144158000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:62163 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S932280AbWFRSxH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 14:53:07 -0400
To: dlezcano@fr.ibm.com
Content-Disposition: inline
In-Reply-To: <20060609210625.144158000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2006 at 11:02:04PM +0200, dlezcano@fr.ibm.com wrote:

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

deadlock.


Besides, holding references to net_device from userland is Not Good(tm).
