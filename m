From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take17 1/4] kevent: Core files.
Date: Fri, 8 Sep 2006 10:38:09 +0400
Message-ID: <20060908063808.GA28736@2ka.mipt.ru>
References: <1157623151215@2ka.mipt.ru> <200609072105.16061.shaw@vranix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54426 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751739AbWIHGix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 02:38:53 -0400
To: shaw@vranix.com
Content-Disposition: inline
In-Reply-To: <200609072105.16061.shaw@vranix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2006 at 09:05:16PM -0700, shaw@vranix.com (shaw@vranix.com) wrote:
> > +static int __devinit kevent_user_init(void)
> > +{
> > +	int err = 0;
> > +
> > +	kevent_cache = kmem_cache_create("kevent_cache",
> > +			sizeof(struct kevent), 0, SLAB_PANIC, NULL, NULL);
> > +
> > +	err = misc_register(&kevent_miscdev);
> > +	if (err) {
> > +		printk(KERN_ERR "Failed to register kevent miscdev: err=%d.\n", err);
> > +		goto err_out_exit;
> > +	}
> > +
> > +	printk("KEVENT subsystem has been successfully registered.\n");
> > +
> > +	return 0;
> > +
> > +err_out_exit:
> > +	kmem_cache_destroy(kevent_cache);
> > +	return err;
> > +}
> 
> It's probably best to treat kmem_cache_create like a black box and check for 
> it returning null.

It can not return NULL, it will panic instead since I use SLAB_PANIC
flag.

> Thanks,
> Shaw

-- 
	Evgeniy Polyakov
