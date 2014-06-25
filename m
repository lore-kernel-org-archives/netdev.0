From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 03/12] net: remove inet6_reqsk_alloc
Date: Wed, 25 Jun 2014 16:17:33 -0700 (PDT)
Message-ID: <20140625.161733.1604668220222889933.davem@davemloft.net>
References: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
	<1403548969-12303-4-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbaFYXRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:17:34 -0400
In-Reply-To: <1403548969-12303-4-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Mon, 23 Jun 2014 21:42:40 +0300

> Since pktops is only used for IPv6 only and opts is used for IPv4
> only, we can move these fields into a union and this allows us to drop
> the inet6_reqsk_alloc function as after this change it becomes
> equivalent with inet_reqsk_alloc.
> 
> This patch also fixes an kmemcheck issue in the IPv6 stack: the flags
> field was not annotated after a request_sock was allocated.
> 
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>

What about ipv4 mapped ipv6 connections?  I don't think it's safe to
share the space for these two fields.
