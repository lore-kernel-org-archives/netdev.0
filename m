From: Brandon Philips <bphilips@suse.de>
Subject: Re: [patch 2/5][RFC] Update net core to use devres.
Date: Fri, 3 Aug 2007 02:39:07 -0700
Message-ID: <20070803093907.GA5872@ifup.org>
References: <20070802224527.GD5181@ifup.org> <46B2F1B9.9010605@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tejun Heo <teheo@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:38574 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757461AbXHCJjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 05:39:11 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id CC1AB125C8
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2007 11:39:10 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <46B2F1B9.9010605@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18:13 Fri 03 Aug 2007, Tejun Heo wrote:
> > +	p = devres_alloc(devm_free_netdev, 0, GFP_KERNEL);
> 
> s/0/sizeof(*p)/

Oops!  It should have read like this:

+static void * register_netdev_devres(struct device *gendev,
+                                               struct net_device *dev)
+{
+       void *p;
+
+       /* 0 size because we don't need it. The net_device is already alloc'd
+        * in alloc_netdev_mq.  We can't use devm_kzalloc in alloc_netdev_mq
+        * because a net_device cannot be free'd directly as it can be a
+        * kobject.  See free_netdev.
+        */
+       p = devres_alloc(devm_free_netdev, 0, GFP_KERNEL);
+
+       if (unlikely(!p))
+               return NULL;
+
+       devres_add(gendev, p);
+
+       return dev;
+}

I will send the full correct patch.

Thanks,

	Brandon
