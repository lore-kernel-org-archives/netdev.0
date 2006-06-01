From: David Miller <davem@davemloft.net>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 17:09:08 -0700 (PDT)
Message-ID: <20060531.170908.46214247.davem@davemloft.net>
References: <20060531045811.GA6977@gondor.apana.org.au>
	<20060530.221117.85394939.davem@davemloft.net>
	<1149110429.3078.5.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38822
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751672AbWFAAIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 20:08:37 -0400
To: mchan@broadcom.com
In-Reply-To: <1149110429.3078.5.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 31 May 2006 14:20:29 -0700

> David, So do we want to fix this issue as proposed by Herbert to replace
> tx_lock with xmit_lock? It seems quite straightforward to do. For this
> change to work, netpoll also needs to be fixed up a bit to check for
> LLTX before getting the xmit_lock.

Oh yes, netpoll needs changes, thanks for noticing that.

That's why I had the idea to make xmit_lock a pointer, so
that things like that netpoll case could be transparent.

I think this netpoll wrinkle means we also have to make
sure to set the xmit_lock_owner across the board.
