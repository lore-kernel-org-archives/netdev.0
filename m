From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 0/2] net: fixes for device unregistration
Date: Fri, 10 Jul 2015 18:17:30 -0700 (PDT)
Message-ID: <20150710.181730.818304125134557032.davem@davemloft.net>
References: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	stephen@networkplumber.org, linuxbugs@vittgam.net
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbGKGFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:05:30 -0400
In-Reply-To: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu,  9 Jul 2015 09:59:08 +0300

> Test script from Eric W. Biederman can catch a problem
> where packets from backlog are processed long after the last
> synchronize_net call. This can be reproduced after few tests
> if commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
> is reverted for the test. Incoming packets do not hold
> reference to device but even if they do, subsystems do not
> expect packets to fly during and after the NETDEV_UNREGISTER
> event.
> 
> The first fix has the cost of netif_running check in fast path.
> The second fix calls rcu_read_lock while local IRQ is disabled,
> I hope this is not against the rules.

Thanks for fixing this tricky bug.

Applied and queued up for -stable.
