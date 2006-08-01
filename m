From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: only set err in rawv6_bind() when necessary
Date: Tue, 01 Aug 2006 15:03:52 -0700 (PDT)
Message-ID: <20060801.150352.104034113.davem@davemloft.net>
References: <44CF89FB.2060208@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54178
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751151AbWHAWDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:03:53 -0400
To: brian.haley@hp.com
In-Reply-To: <44CF89FB.2060208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 01 Aug 2006 13:06:03 -0400

> The variable 'err' is set in rawv6_bind() before the address check fails 
> instead of after, moved inside if() statement.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

This is a common C idiom in the kernel:

	err = -EWHATEVER;
	if (error_condition)
		goto out;

	err = 0;
out:
	unlock_stuff();
	return err;

Every other path going from this location in rawv6_bind()
will clear err to zero, so your patch also doesn't fix any
bug.
