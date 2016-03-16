From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ppp: ensure file->private_data can't be
 overridden
Date: Wed, 16 Mar 2016 19:39:04 -0400 (EDT)
Message-ID: <20160316.193904.361799863419478191.davem@davemloft.net>
References: <7866074a3c03ea15640aa72ef2553987862bc8b6.1457986520.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, alan@linux.intel.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbcCPXjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:39:07 -0400
In-Reply-To: <7866074a3c03ea15640aa72ef2553987862bc8b6.1457986520.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 14 Mar 2016 21:17:16 +0100

> Locking ppp_mutex must be done before dereferencing file->private_data,
> otherwise it could be modified before ppp_unattached_ioctl() takes the
> lock. This could lead ppp_unattached_ioctl() to override ->private_data,
> thus leaking reference to the ppp_file previously pointed to.
> 
> v2: lock all ppp_ioctl() instead of just checking private_data in
>     ppp_unattached_ioctl(), to avoid ambiguous behaviour.
> 
> Fixes: f3ff8a4d80e8 ("ppp: push BKL down into the driver")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks!
