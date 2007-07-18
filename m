From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [net/core] move dev_mc_discard from dev_mcast.c to
 dev.c
Date: Wed, 18 Jul 2007 02:11:07 -0700 (PDT)
Message-ID: <20070718.021107.40833440.davem@davemloft.net>
References: <11846606051099-git-send-email-crquan@gmail.com>
	<11847264651509-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756088AbXGRJLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:11:08 -0400
In-Reply-To: <11847264651509-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng <crquan@gmail.com>
Date: Wed, 18 Jul 2007 10:41:03 +0800

> Because this function is only called by unregister_netdevice,
> this moving could make this non-global function static,
> and also remove its declaration in netdevice.h;
> 
> Any further, function __dev_addr_discard is also just called by
> dev_mc_discard and dev_unicast_discard, keeping this two functions
> both in one c file could make __dev_addr_discard also static
> and remove its declaration in netdevice.h;
> 
> Futhermore, the sequential call to dev_unicast_discard and then
> dev_mc_discard in unregister_netdevice have a similar mechanism that:
> (netif_tx_lock_bh / __dev_addr_discard / netif_tx_unlock_bh),
> they should merged into one to eliminate duplicates in acquiring and
> releasing the dev->_xmit_lock, this would be done in my following patch.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Patch applied, thanks.
