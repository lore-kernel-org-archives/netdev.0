From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bonding: fix div by zero while enslaving and
 transmitting
Date: Sat, 13 Sep 2014 17:17:46 -0400 (EDT)
Message-ID: <20140913.171746.547311064738045536.davem@davemloft.net>
References: <5413097B.9080802@redhat.com>
	<1410536298-8022-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, andy@greyhouse.net,
	j.vosburgh@gmail.com, vfalico@gmail.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbaIMVRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:17:48 -0400
In-Reply-To: <1410536298-8022-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Fri, 12 Sep 2014 17:38:18 +0200

> The problem is that the slave is first linked and slave_cnt is
> incremented afterwards leading to a div by zero in the modes that use it
> as a modulus. What happens is that in bond_start_xmit()
> bond_has_slaves() is used to evaluate further transmission and it becomes
> true after the slave is linked in, but when slave_cnt is used in the xmit
> path it is still 0, so fetch it once and transmit based on that. Since
> it is used only in round-robin and XOR modes, the fix is only for them.
> Thanks to Eric Dumazet for pointing out the fault in my first try to fix
> this.
  ...
> Fixes: 278b208375 ("bonding: initial RCU conversion")
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> v2: Based on Eric's feedback change the fix to fetch the value once in a
>     local variable in the affected modes and to act based on that.

Applied and queued up for -stable, thanks.
