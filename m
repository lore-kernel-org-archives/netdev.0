From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/2] linux-wpan-next: lowpan_rcv - skb is freed within function and fix return values.
Date: Wed, 30 Jul 2014 10:42:09 -0700
Message-ID: <C8606BA6-2918-4313-BEC5-FC3A377DE347@holtmann.org>
References: <1406732105-17500-1-git-send-email-martin.townsend@xsilon.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-zigbee-devel@lists.sourceforge.net,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Martin Townsend <martin.townsend@xsilon.com>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>
To: Martin Townsend <mtownsend1973@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60514 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662AbaG3RmL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 13:42:11 -0400
In-Reply-To: <1406732105-17500-1-git-send-email-martin.townsend@xsilon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

> Currently it is up to the functions below lowpan_rcv to free the skb on error
>    conditions.  This patch now removes all the UAPI error codes and process data
>    now returns -1 if there is a problem.  In this scenario lowpan_rcv will free
>    the skb and return NET_RX_DROP.  This also fixes the problem where
>    NET_RX_SUCCESS is returned on error
> 
> Martin Townsend (2):
>  Remove dev parameter from skb_delivery_cb in 6lowpan.
>  Change lowpan_rcv so skb is freed within function and fix return
>    values.
> 
> include/net/6lowpan.h         |  4 ++--
> net/6lowpan/iphc.c            | 37 ++++++++++++++++++------------------
> net/bluetooth/6lowpan.c       | 21 ++++++++++-----------
> net/ieee802154/6lowpan_rtnl.c | 44 +++++++++++++++++++++----------------------
> 4 files changed, 52 insertions(+), 54 deletions(-)

I can not take these patches at this point.

checking file net/ieee802154/6lowpan_rtnl.c
Hunk #1 FAILED at 143.
Hunk #2 succeeded at 480 (offset -4 lines).
1 out of 2 hunks FAILED

We need to get the IEEE 802.15.4 changes merged through John's wireless-next tree. IEEE 802.15.4 going straight into net-next and Bluetooth going into wireless-next will not work out smoothly when both technologies are now utilizing 6LoWPAN and we are heavily working on 6LoWPAN.

John, how confident are you with pulling net-next into wireless-next at this point in time?

Regards

Marcel
