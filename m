From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V1 1/3] net/mlx4_en: Don't use irq_affinity_notifier
 to track changes in IRQ affinity map
Date: Mon, 30 Jun 2014 02:11:52 -0700
Message-ID: <1404119512.15139.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
		 <1404032097-5132-2-git-send-email-amirv@mellanox.com>
	 <1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53B1210E.6040409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ben Hutchings <ben@decadent.org.uk>, amira@mellanox.com,
	Yuval Atias <yuvala@mellanox.com>
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:54373 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbaF3JL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 05:11:57 -0400
Received: by mail-we0-f175.google.com with SMTP id k48so7905770wev.20
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 02:11:56 -0700 (PDT)
In-Reply-To: <53B1210E.6040409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-30 at 11:34 +0300, Amir Vadai wrote:

> TX completions are very quick compared to the skb preparation and
> sending. Which is not the case for RX completions. Because of that, it
> is very easy to reproduce the problem in RX flows, but we never had any
> report of that problem in the TX flow.

This is because reporters probably use same number of RX and TX queues.

With TCP Small queues, TX completions are not always quick, if thousands
of flows are active.

Some people hit the locked cpu when say one cpu has to drain 8 TX
queues, because 7 other cpus can continuously feed more packets 

> I prefer not to spend time on the TX, since we plan to send a patch soon
> to use the same NAPI for both TX and RX.

Thanks, this sounds great.
