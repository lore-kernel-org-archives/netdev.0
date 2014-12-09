From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Tue, 09 Dec 2014 13:37:19 -0500 (EST)
Message-ID: <20141209.133719.510437323986645419.davem@davemloft.net>
References: <1417643184-23440-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	roopa@cumulusnetworks.com, makita.toshiaki@lab.ntt.co.jp
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbaLIShW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:37:22 -0500
In-Reply-To: <1417643184-23440-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed,  3 Dec 2014 13:46:24 -0800

> The commit 56bfa7ee7c ("unregister_netdevice : move RTM_DELLINK to
> until after ndo_uninit") tried to do this ealier but while doing so
> it created a problem. Unfortunately the delayed rtmsg_ifinfo() also
> delayed call to fill_info(). So this translated into asking driver
> to remove private state and then query it's private state. This
> could have catastropic consequences.
> 
> This change breaks the rtmsg_ifinfo() into two parts - one takes the
> precise snapshot of the device by called fill_info() before calling
> the ndo_uninit() and the second part sends the notification using
> collected snapshot.
> 
> It was brought to notice when last link is deleted from an ipvlan device
> when it has free-ed the port and the subsequent .fill_info() call is
> trying to get the info from the port.
...
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David S. Miller <davem@davemloft.net>

Applied.
