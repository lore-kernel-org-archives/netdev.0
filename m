From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: remove NETDEV_TX_BUSY
Date: Tue, 07 Oct 2014 11:30:06 +0300
Message-ID: <5433A48E.1040505@gmail.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>	 <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com> <1412613035.11091.72.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:43975 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbaJGIaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 04:30:12 -0400
Received: by mail-wi0-f176.google.com with SMTP id hi2so7016728wib.9
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 01:30:10 -0700 (PDT)
In-Reply-To: <1412613035.11091.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/2014 7:30 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Drivers should avoid NETDEV_TX_BUSY as much as possible.
> 
> They should stop the tx queue before qdisc even tries to push another
> packet, to avoid requeues.
> 
> For a driver supporting skb->xmit_more, this is likely to be a prereq
> anyway, otherwise we could have a tx deadlock : We need to force a
> doorbell if TX ring is full.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Reviewed. Also verified that it fixes the deadlock (by sending a large
burst - larger than ring size). Before this fix, last packet of the
burst wasn't sent, therefore no doorbell was rang, and the queue was
stalled.

BTW, another nice optimization that we hope to send soon, is not to arm
the CQ unless ringing the doorbell.

Acked-by: Amir Vadai <amirv@mellanox.com>
