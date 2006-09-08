From: shaw@vranix.com
Subject: Re: [take17 1/4] kevent: Core files.
Date: Thu, 7 Sep 2006 21:05:16 -0700
Message-ID: <200609072105.16061.shaw@vranix.com>
References: <1157623151215@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-green-bigip-98.dreamhost.com ([208.97.132.98]:56520 "EHLO
	postalmail-a3.dreamhost.com") by vger.kernel.org with ESMTP
	id S1752076AbWIHEFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 00:05:19 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <1157623151215@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int __devinit kevent_user_init(void)
> +{
> +	int err = 0;
> +
> +	kevent_cache = kmem_cache_create("kevent_cache",
> +			sizeof(struct kevent), 0, SLAB_PANIC, NULL, NULL);
> +
> +	err = misc_register(&kevent_miscdev);
> +	if (err) {
> +		printk(KERN_ERR "Failed to register kevent miscdev: err=%d.\n", err);
> +		goto err_out_exit;
> +	}
> +
> +	printk("KEVENT subsystem has been successfully registered.\n");
> +
> +	return 0;
> +
> +err_out_exit:
> +	kmem_cache_destroy(kevent_cache);
> +	return err;
> +}

It's probably best to treat kmem_cache_create like a black box and check for 
it returning null.

Thanks,
Shaw
