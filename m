From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: Flush all skbs related to an
 unregistered device
Date: Thu, 21 May 2015 17:02:19 -0400 (EDT)
Message-ID: <20150521.170219.1689248066169954260.davem@davemloft.net>
References: <1432077893-4431-1-git-send-email-baptiste@arista.com>
	<1432077893-4431-2-git-send-email-baptiste@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fruggeri@arista.com, mowat@arista.com,
	adrien+dev@schischi.me
To: baptiste@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755792AbbEUVCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 17:02:22 -0400
In-Reply-To: <1432077893-4431-2-git-send-email-baptiste@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baptiste Covolato <baptiste@arista.com>
Date: Tue, 19 May 2015 16:24:51 -0700

> Update flush_backlog to flush all packets in the backlog queue belonging
> to a device being unregistered. Accordingly on_each_cpu no longer needs
> to pass a device to flush_backlog since it handles any device in the
> NETREG_UNREGISTERED state.
> 
> Signed-off-by: Baptiste Covolato <baptiste@arista.com>
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

This is quite bogus if you ask me.

This is the one spot causing a device to make the transition
to unregistered state, so passing that specific device to
flush_backlog() is the completely logical way to handle this.

If this is some hack that is made necessary by your parallel
notification scheme, I do not find it acceptable.

I'm not applying this series, sorry.
