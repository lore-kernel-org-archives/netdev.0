From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc_cmsg_rcv was getting called after sk_eat_skb.
Date: Mon, 19 Dec 2011 15:59:02 -0500 (EST)
Message-ID: <20111219.155902.868162865948757576.davem@davemloft.net>
References: <1324026085-11812-1-git-send-email-ajuncu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	alex.juncu@rosedu.org, knaik@ixiacom.com, shemminger@vyatta.com
To: ajuncu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab1LSU7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 15:59:10 -0500
In-Reply-To: <1324026085-11812-1-git-send-email-ajuncu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandru Juncu <ajuncu@ixiacom.com>
Date: Fri, 16 Dec 2011 11:01:25 +0200

> Received non stream protocol packets were calling llc_cmsg_rcv that used a
> skb after that skb was released by sk_eat_skb. This caused received STP
> packets to generate kernel panics.
> 
> Signed-off-by: Alexandru Juncu <ajuncu@ixiacom.com>
> Signed-off-by: Kunjan Naik <knaik@ixiacom.com>

This bug was introduced by commit 30a584d944fbd599d4a8f470f75bf7af1a15b466:

commit 30a584d944fbd599d4a8f470f75bf7af1a15b466
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Thu Aug 3 16:38:49 2006 -0700

    [LLX]: SOCK_DGRAM interface fixes

The new logic added by this fix is slightly clumsy, but seems correct
and I can't suggest a better fix at this time.

I'll apply this, thanks.
