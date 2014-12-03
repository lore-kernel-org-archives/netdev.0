From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next v2] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Wed, 03 Dec 2014 12:41:22 +0900
Message-ID: <547E8662.4090400@lab.ntt.co.jp>
References: <1417574617-27560-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:53495 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbaLCDle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 22:41:34 -0500
In-Reply-To: <1417574617-27560-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/03 11:43, Mahesh Bandewar wrote:
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
> 
...
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Report-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

s/Report-by/Reported-by/

Thanks,
Toshiaki Makita
