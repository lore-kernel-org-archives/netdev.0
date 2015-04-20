From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 04/10] ipv6: Only create RTF_CACHE routes after
 encountering pmtu exception
Date: Mon, 20 Apr 2015 14:28:41 -0400 (EDT)
Message-ID: <20150420.142841.583067282489152059.davem@davemloft.net>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
	<1428717253-1006248-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755018AbbDTS2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 14:28:43 -0400
In-Reply-To: <1428717253-1006248-5-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 10 Apr 2015 18:54:07 -0700

> +	if (!(rt6->rt6i_flags & RTF_CACHE) &&
> +	    (!(rt6->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)) ||
> +	     !(rt6->dst.flags & DST_HOST))) {

These big convoluted tests are tiring to read over and over again.

At the very least, "(rt6->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)"
deserves to be a descriptively named inline function.
