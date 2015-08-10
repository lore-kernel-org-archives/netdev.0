From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: track link status of ipv6 nexthops
Date: Mon, 10 Aug 2015 10:54:00 -0700 (PDT)
Message-ID: <20150810.105400.1277861088010551746.davem@davemloft.net>
References: <1438875754-28025-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbbHJRyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:54:03 -0400
In-Reply-To: <1438875754-28025-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Thu,  6 Aug 2015 11:42:33 -0400

> Add support to track current link status of ipv6 nexthops to match
> recent changes that added support for ipv4 nexthops.  There was not a
> field already available that could track these and no space available in
> the existing rt6i_flags field, so this patch adds rt6i_nhflags to struct
> rt6_info.
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>

This doesn't really make any sense to me.

You can evaluate the state of the link at the time you look at the
route at all of the places where it matters as far as I can tell.

It's so expensive to walk the entire routing table every time a link
goes up and down, so it's much better to take an "evaluate as needed"
approach to implementing this.
