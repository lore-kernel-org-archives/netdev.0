From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH net-next-2.6] net: add dev_close_many
Date: Mon, 13 Dec 2010 22:54:24 +0200
Message-ID: <201012132254.24267.opurdila@ixiacom.com>
References: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com> <201012131952.39648.opurdila@ixiacom.com> <20101213100447.50f77f3b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"Lucian Adrian Grijincu" <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:7478 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755941Ab0LMUy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 15:54:26 -0500
In-Reply-To: <20101213100447.50f77f3b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Monday 13 December 2010, 20:04:47

> I assume the need for dev_close_many is coming from a user space
> application?
> 
> I expect that for this kind of special need,  you would be better off not
> using the normal iproute utilities and instead have a custom device manager
> that is doing netlink directly.
> 
> Rather than doing synchronous send request and wait for ack. The utility
> could use a sender and collector thread.

Actually we need dev_close_many in order to speed up netdev_unregister_many 
since in the netdev_unregister_many path there is still one more sync-rcu 
operation which is not factorized.

I will prepare v2 to address David's comment and I will also be more explicit 
in the commit message.
