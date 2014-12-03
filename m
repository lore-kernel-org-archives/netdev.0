From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Wed, 03 Dec 2014 14:07:55 -0800
Message-ID: <1417644475.5303.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417643184-23440-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:59203 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbaLCWH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 17:07:57 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so13611471igb.11
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 14:07:57 -0800 (PST)
In-Reply-To: <1417643184-23440-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-03 at 13:46 -0800, Mahesh Bandewar wrote:
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


> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
