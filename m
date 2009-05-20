From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] powerpc/ep8248e: phylib needs NET_SCHED to build
Date: Wed, 20 May 2009 12:26:22 -0700 (PDT)
Message-ID: <20090520.122622.112939264.davem@davemloft.net>
References: <1242821902-16836-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755606AbZETT0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:26:24 -0400
In-Reply-To: <1242821902-16836-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Wed, 20 May 2009 16:18:22 +0400

> Fix this build error:
> drivers/built-in.o: In function `phy_state_machine':
> drivers/net/phy/phy.c:893: undefined reference to 'netif_carrier_off'
> drivers/net/phy/phy.c:854: undefined reference to 'netif_carrier_on'
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

This isn't right.  Otherwise no networking driver would build
with NET_SCHED disabled.

net/sched/sch_generic.c is always built when NET is enabled
and that's where netif_carrier_off() is defined.

As you can see in net/sched/Makefile, sch_generic.o is
"obj-y", did you even check? :-)
