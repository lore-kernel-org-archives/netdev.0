From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] net: The beginning of the end for
 NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM
Date: Tue, 15 Dec 2015 16:32:33 -0500 (EST)
Message-ID: <20151215.163233.1822498299187427740.davem@davemloft.net>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206AbbLOVch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 16:32:37 -0500
In-Reply-To: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 14 Dec 2015 11:19:39 -0800

> This patch set starts to address one front in the battle against
> protocol ossification.

Looks good series applied, thanks.

Two things:

1) I'd ask you to reconsider passing that struct with the bit fields into
   the chk routines.  Some cpu ABIs pass that thing as an aggregate on
   the stack.  Whereas if you just use a simple bit mask and BIT(x) values
   we know it's always going to be passed in as an integer or whatever.

2) As per the TCP check, it is definitely more strict now.  But I seriously
   doubt get ever gained anything real with the previous, looser, check.
   Besides, if it bites a user segment we will get a report and can adjust
   things.

Thanks!
