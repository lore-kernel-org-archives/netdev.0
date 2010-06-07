From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Mon, 07 Jun 2010 12:14:46 +0200
Message-ID: <1275905686.29978.3.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	 <1275829701.3615.54.camel@jlt3.sipsolutions.net>
	 <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	 <1275903773.29978.1.camel@jlt3.sipsolutions.net>
	 <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:51133 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab0FGKOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 06:14:53 -0400
In-Reply-To: <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-07 at 11:53 +0200, Kay Sievers wrote:

> > Can you please tell me then how to device_create() without a class? I
> > cannot seem to create devices without a class at all, even using manual
> > allocation (yuck) and device_register crashes the kernel.
> 
> Right, this "convenience API" does not exist for buses. It's not doing
> much, just allocates a "struct device" and fills in the few values and
> calls device_register().
> 
> Does your device create a device node? If not, device_create() should
> not be used anyway, because the corresponding device_destroy() will
> not do anything.

No, it doesn't need a dev node. I tried this:

+               data->dev = kzalloc(sizeof(struct device), GFP_KERNEL);
+               if (!data->dev) {
                        err = -ENOMEM;
                        goto failed_drvdata;
                }
+
+               dev_set_name(data->dev, "hwsim%d", i);
+               data->dev->bus = &hwsim_bus;
                data->dev->driver = &mac80211_hwsim_driver;
 
+               err = device_register(data->dev);
+               if (err) {
+                       printk(KERN_DEBUG
+                              "mac80211_hwsim: device_register failed (%d)\n",
+                              err);
+                       goto failed_drvdata;
+               }

(ignore the pluses, snipped from a patch) but it ran into a null ptr
deref?

johannes

