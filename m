From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: fix unilateral interrupt disabling in
 netpoll path
Date: Tue, 27 Oct 2015 19:46:02 -0700 (PDT)
Message-ID: <20151027.194602.2000759526217015723.davem@davemloft.net>
References: <1445876662-7946-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963AbbJ1C3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:29:21 -0400
In-Reply-To: <1445876662-7946-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 26 Oct 2015 12:24:22 -0400

> Forcedeth currently uses disable_irq_lockdep and enable_irq_lockdep, which in
> some configurations simply calls local_irq_disable.  This causes errant warnings
> in the netpoll path as in netpoll_send_skb_on_dev, where we disable irqs using
> local_irq_save, leading to the following warning:
 ...
> Fix it by modifying the forcedeth code to use
> disable_irq_nosync_lockdep_irqsavedisable_irq_nosync_lockdep_irqsave instead,
> which saves and restores irq state properly.  This also saves us a little code
> in the process
> 
> Tested by the reporter, with successful restuls
> 
> Patch applies to the head of the net tree
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> Reported-by: Vasily Averin <vvs@sw.ru>

Applied, thanks.
