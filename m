From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: ensure file->private_data can't be overridden
Date: Fri, 11 Mar 2016 14:42:16 -0500 (EST)
Message-ID: <20160311.144216.676727973447663610.davem@davemloft.net>
References: <3f04de903b6be9e1c30427830c0a1568478e0c6c.1457462784.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, alan@linux.intel.com,
	arnd@arndb.de
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbcCKTmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:42:19 -0500
In-Reply-To: <3f04de903b6be9e1c30427830c0a1568478e0c6c.1457462784.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 8 Mar 2016 20:14:30 +0100

> Lock ppp_mutex and check that file->private_data is NULL before
> executing any action in ppp_unattached_ioctl().
> The test done by ppp_ioctl() can't be relied upon, because
> file->private_data may have been updated meanwhile. In which case
> ppp_unattached_ioctl() will override file->private_data and mess up
> reference counters or loose pointer to previously allocated PPP unit.
> 
> In case the test fails, -ENOTTY is returned, just like if ppp_ioctl()
> had rejected the ioctl in the first place.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

If this thing can disappear on us, then we need to make the entirety
of ppp_ioctl() run with the mutex held to fix this properly.

Otherwise ->private_data could go NULL on us meanwhile as well.

We should hold the mutex, to stabilize the value of ->private_data.
