From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: ipv6: Make address flushing on ifdown
 optional
Date: Sun, 11 Oct 2015 04:44:49 -0700 (PDT)
Message-ID: <20151011.044449.2122530094518900731.davem@davemloft.net>
References: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com,
	nicolas.dichtel@6wind.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbbJKL2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 07:28:55 -0400
In-Reply-To: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  7 Oct 2015 08:17:39 -0700

> +static void fixup_managed_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
> +{
> +	if (!ifp->rt)
> +		ifp->rt = addrconf_dst_alloc(idev, &ifp->addr, false);

This potentially leaves an error pointer dangling in ifp->rt
