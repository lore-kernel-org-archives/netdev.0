From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Tue, 27 Apr 2010 14:32:22 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:47610 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755364Ab0D0Mcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 08:32:36 -0400
In-Reply-To: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Apr 2010, Peter P Waskiewicz Jr wrote:
> +/**
> + * struct irqaffinityhint - per interrupt affinity helper
> + * @callback:	device driver callback function
> + * @dev:	reference for the affected device
> + * @irq:	interrupt number
> + */
> +struct irqaffinityhint {
> +	irq_affinity_hint_t callback;
> +	void *dev;
> +	int irq;
> +};

Why do you need that extra data structure ? The device and the irq
number are known, so all you need is the callback itself. So no need
for allocating memory ....

> +static ssize_t irq_affinity_hint_proc_write(struct file *file,
> +		const char __user *buffer, size_t count, loff_t *pos)
> +{
> +	/* affinity_hint is read-only from proc */
> +	return -EOPNOTSUPP;
> +}
> +

Why do you want a write function when the file is read only ?

Thanks,

	tglx
