From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: release the spinlock before
 __netpoll_cleanup()
Date: Thu, 07 Mar 2013 16:14:38 -0500 (EST)
Message-ID: <20130307.161438.396456319050281566.davem@davemloft.net>
References: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
	<20130307000824.GA5702@neilslaptop.think-freely.org>
	<20130307100325.GA31105@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, amwang@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200Ab3CGVOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:14:40 -0500
In-Reply-To: <20130307100325.GA31105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 7 Mar 2013 11:03:25 +0100

> @@ -680,9 +681,21 @@ static int netconsole_netdev_event(struct
> notifier_block *this,
>  				 * rtnl_lock already held
>  				 */
>  				if (nt->np.dev) {
> +					/*
> +					 * we still might sleep in
> + * __netpoll_cleanup(), so release
> +					 * the lock and restart

Quite a bit of email corruption of this patch.

Also, this code block is probably too deeply indented to be sane,
consider creating a small helper function to call instead.
