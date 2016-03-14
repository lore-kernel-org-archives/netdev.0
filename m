From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: ensure file->private_data can't be overridden
Date: Mon, 14 Mar 2016 14:57:59 -0400 (EDT)
Message-ID: <20160314.145759.727527672385295428.davem@davemloft.net>
References: <3f04de903b6be9e1c30427830c0a1568478e0c6c.1457462784.git.g.nault@alphalink.fr>
	<20160311.144216.676727973447663610.davem@davemloft.net>
	<20160314175940.GB1462@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, alan@linux.intel.com,
	arnd@arndb.de
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbcCNS6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:58:04 -0400
In-Reply-To: <20160314175940.GB1462@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 14 Mar 2016 18:59:40 +0100

> Testing ->private_data without lock in ppp_ioctl() before calling
> ppp_unattached_ioctl() is fine, because either ->private_data is
> not NULL and thus is stable, or it is and ppp_unattached_ioctl()
> takes care of not overriding ->private_data, should its value get
> modified before taking the mutex.

This is exactly the ambiguous behavior I want you to avoid.

The decision should be atomic from ppp_ioctl()'s test all the way
until ppp_unattached_ioctl() does it's work.
