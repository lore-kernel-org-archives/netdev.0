From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tehuti: using uninitialized data in bdx_ioctl_priv()
Date: Mon, 24 Jun 2013 13:01:45 -0700 (PDT)
Message-ID: <20130624.130145.1513695698751905735.davem@davemloft.net>
References: <20130624160503.GC31984@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab3FXUBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:01:46 -0400
In-Reply-To: <20130624160503.GC31984@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 24 Jun 2013 19:05:03 +0300

> If we "cmd == SIOCDEVPRIVATE" then we use data[] without initializing
> it.  The most common case is that we would return -EOPNOTSUPP.  The
> other case is that we'd end up reading and writing to randomish places.
> This requires CAP_SYS_RAWIO so it's not very bad.
> 
> The fix is to not allow SIOCDEVPRIVATE because it doesn't work.  I
> returned -EOPNOTSUPP instead of -ENOTTY because that's what is used in
> the rest of the file.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

I think the intention is to only allow SIOCDEVPRIVATE, rather than
accept any and all values other than it which are inside of the
private ioctl range.

The 'cmd' validation is one step, and it determines the interpretation
of data[0].
