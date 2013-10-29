From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3] xen-netback: use jiffies_64 value to calculate
 credit timeout
Date: Tue, 29 Oct 2013 00:25:17 -0400 (EDT)
Message-ID: <20131029.002517.1798687875318867376.davem@davemloft.net>
References: <1382962077-13406-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	david.vrabel@citrix.com, jbeulich@suse.com, annie.li@oracle.com,
	ian.campbell@citrix.com, jianhai.luan@oracle.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab3J2EZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:25:19 -0400
In-Reply-To: <1382962077-13406-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 28 Oct 2013 12:07:57 +0000

> time_after_eq() only works if the delta is < MAX_ULONG/2.
> 
> For a 32bit Dom0, if netfront sends packets at a very low rate, the time
> between subsequent calls to tx_credit_exceeded() may exceed MAX_ULONG/2
> and the test for timer_after_eq() will be incorrect. Credit will not be
> replenished and the guest may become unable to send packets (e.g., if
> prior to the long gap, all credit was exhausted).
> 
> Use jiffies_64 variant to mitigate this problem for 32bit Dom0.
> 
> Suggested-by: Jan Beulich <jbeulich@suse.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Applied and queued up for -stable, thanks.
