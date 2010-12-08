From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] llc: fix a device refcount imbalance
Date: Wed, 08 Dec 2010 09:59:20 -0800 (PST)
Message-ID: <20101208.095920.229730656.davem@davemloft.net>
References: <1291537161.2806.109.camel@edumazet-laptop>
	<1291548233.2806.212.camel@edumazet-laptop>
	<1291550606.2806.237.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maximlevitsky@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	opurdila@ixiacom.com, stable@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60777
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754912Ab0LHR6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 12:58:53 -0500
In-Reply-To: <1291550606.2806.237.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Dec 2010 13:03:26 +0100

> [PATCH net-2.6] llc: fix a device refcount imbalance
> 
> commit abf9d537fea225 (llc: add support for SO_BINDTODEVICE) added one
> refcount imbalance in llc_ui_bind(), because dev_getbyhwaddr() doesnt
> take a reference on device, while dev_get_by_index() does.
> 
> Fix this using RCU locking. And since an RCU conversion will be done for
> 2.6.38 for dev_getbyhwaddr(), put the rcu_read_lock/unlock exactly at
> their final place.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.
