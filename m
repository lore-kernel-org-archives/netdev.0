From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH] try parent numa_node at first before using default
Date: Fri, 13 Jul 2007 07:48:06 +0200
Message-ID: <20070713074806.6a641528@gondolin.boeblingen.de.ibm.com>
References: <200707101641.17672.yinghai.lu@sun.com>
	<469610D4.70009@s5r6.in-berlin.de>
	<20070712172310.4d662e1f@gondolin.boeblingen.de.ibm.com>
	<200707121059.54320.yinghai.lu@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:38776 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbXGMFtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 01:49:21 -0400
In-Reply-To: <200707121059.54320.yinghai.lu@sun.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 10:59:53 -0700,
Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:

> @@ -1285,8 +1290,11 @@ int device_move(struct device *dev, struct device *new_parent)
>  	dev->parent = new_parent;
>  	if (old_parent)
>  		klist_remove(&dev->knode_parent);
> -	if (new_parent)
> +	if (new_parent) {
>  		klist_add_tail(&dev->knode_parent, &new_parent->klist_children);
> +		set_dev_node(dev, dev_to_node(new_parent));
> +	}
> +
>  	if (!dev->class)
>  		goto out_put;
>  	error = device_move_class_links(dev, old_parent, new_parent);

You're not correctly undoing the changes if the last function fails.
