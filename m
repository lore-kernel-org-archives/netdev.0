From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: prevent init path from scheduling on the
 wrong cpu
Date: Wed, 02 May 2012 21:02:58 -0400 (EDT)
Message-ID: <20120502.210258.1086419954037969029.davem@davemloft.net>
References: <1335896282-11738-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab2ECBET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:04:19 -0400
In-Reply-To: <1335896282-11738-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue,  1 May 2012 14:18:02 -0400

> I just noticed after some recent updates, that the init path for the drop
> monitor protocol has a minor error.  drop monitor maintains a per cpu structure,
> that gets initalized from a single cpu.  Normally this is fine, as the protocol
> isn't in use yet, but I recently made a change that causes a failed skb
> allocation to reschedule itself .  Given the current code, the implication is
> that this workqueue reschedule will take place on the wrong cpu.  If drop
> monitor is used early during the boot process, its possible that two cpus will
> access a single per-cpu structure in parallel, possibly leading to data
> corruption.
> 
> This patch fixes the situation, by storing the cpu number that a given instance
> of this per-cpu data should be accessed from.  In the case of a need for a
> reschedule, the cpu stored in the struct is assigned the rescheule, rather than
> the currently executing cpu
> 
> Tested successfully by myself.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
