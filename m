From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sctp: properly latch and use autoclose value from
 sock to association
Date: Tue, 10 Dec 2013 22:42:11 -0500 (EST)
Message-ID: <20131210.224211.270455193754339098.davem@davemloft.net>
References: <1386350560-20920-1-git-send-email-nhorman@tuxdriver.com>
	<1386676095-15286-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, wangweidong1@huawei.com,
	vyasevich@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab3LKDmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:42:13 -0500
In-Reply-To: <1386676095-15286-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 10 Dec 2013 06:48:15 -0500

> Currently, sctp associations latch a sockets autoclose value to an association
> at association init time, subject to capping constraints from the max_autoclose
> sysctl value.  This leads to an odd situation where an application may set a
> socket level autoclose timeout, but sliently sctp will limit the autoclose
> timeout to something less than that.
> 
> Fix this by modifying the autoclose setsockopt function to check the limit, cap
> it and warn the user via syslog that the timeout is capped.  This will allow
> getsockopt to return valid autoclose timeout values that reflect what subsequent
> associations actually use.
> 
> While were at it, also elimintate the assoc->autoclose variable, it duplicates
> whats in the timeout array, which leads to multiple sources for the same
> information, that may differ (as the former isn't subject to any capping).  This
> gives us the timeout information in a canonical place and saves some space in
> the association structure as well.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks Neil.
