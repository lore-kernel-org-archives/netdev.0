From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Avoid transmits during sky2_down()
Date: Mon, 03 Aug 2009 19:04:21 -0700 (PDT)
Message-ID: <20090803.190421.86873954.davem@davemloft.net>
References: <392fb48f0907310457t15d8f9bbmdf77f062c423a475@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932088AbZHDCEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 22:04:12 -0400
In-Reply-To: <392fb48f0907310457t15d8f9bbmdf77f062c423a475@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Fri, 31 Jul 2009 20:57:42 +0900

> This patch supersedes my previous patch "sky2: Avoid transmitting
> during sky2_restart".
> 
> I have reworked the patch to avoid crashes during both sky2_restart()
> and sky2_set_ringparam().
> 
> Without this patch, the sky2 driver can be crashed by doing:
> 
> # pktgen eth1 &    (transmit many packets on eth1)
> # ethtool -G eth1 tx 510
> 
> I am aware you object to storing extra state, but I can't see a way
> around this. Without remembering that we're restarting,
> netif_wake_queue() is called in the ISR from sky2_tx_complete(), and
> netif_tx_lock() is used in sky2_tx_done().  If anybody can see a way
> around this, please let me know.
> 

Applied, thanks Mike.

> ----
> 
> During sky2_restart() or sky2_set_ringparam(), the tx queue needs to be
>  shutdown in sky2_down() to avoid accessing a NULL tx_ring.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Mike, please don't put your signoff after the "----" seperator,
otherwise automated tools strip it out instead of including it
in the commit message.

Also.

> @@ -2359,7 +2370,7 @@ static inline void sky2_tx_done(struct
> net_device *dev, u16 last)

Your email client breaks up long lines and this corrupts your
patches.  Please correct this before future submissions.

Thanks.
