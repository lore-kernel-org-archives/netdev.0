From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] netns: fix double free at netns creation
Date: Sun, 22 Feb 2009 00:08:01 -0800 (PST)
Message-ID: <20090222.000801.250934892.davem@davemloft.net>
References: <20090220151905.381037040@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20090220152103.537800781@mai-009101017029.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59800
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbZBVIIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:08:19 -0500
In-Reply-To: <20090220152103.537800781@mai-009101017029.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Fri, 20 Feb 2009 16:19:06 +0100

> This patch fix a double free when a network namespace fails.
> The previous code does a kfree of the net_generic structure when
> one of the init subsystem initialization fails.
> The 'setup_net' function does kfree(ng) and returns an error.
> The caller, 'copy_net_ns', call net_free on error, and this one
> calls kfree(net->gen), making this pointer freed twice.
> 
> This patch make the code symetric, the net_alloc does the net_generic
> allocation and the net_free frees the net_generic.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>

Applied, thanks a lot Daniel.
