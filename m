From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: Fix sk_ack_backlog wrap-around problem
Date: Thu, 12 Jun 2014 10:38:14 -0700 (PDT)
Message-ID: <20140612.103814.1635322528200849616.davem@davemloft.net>
References: <1402541616-15117-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xufeng.zhang@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaFLRiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 13:38:16 -0400
In-Reply-To: <1402541616-15117-1-git-send-email-xufeng.zhang@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xufeng Zhang <xufeng.zhang@windriver.com>
Date: Thu, 12 Jun 2014 10:53:36 +0800

> Consider the scenario:
> For a TCP-style socket, while processing the COOKIE_ECHO chunk in
> sctp_sf_do_5_1D_ce(), after it has passed a series of sanity check,
> a new association would be created in sctp_unpack_cookie(), but afterwards,
> some processing maybe failed, and sctp_association_free() will be called to
> free the previously allocated association, in sctp_association_free(),
> sk_ack_backlog value is decremented for this socket, since the initial
> value for sk_ack_backlog is 0, after the decrement, it will be 65535,
> a wrap-around problem happens, and if we want to establish new associations
> afterward in the same socket, ABORT would be triggered since sctp deem the
> accept queue as full.
> Fix this issue by only decrementing sk_ack_backlog for associations in
> the endpoint's list.
> 
> Fix-suggested-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
> Change for v2:
>   Drop the redundant test for temp suggested by Vlad Yasevich.

Applied and queued up for -stable, thanks.
