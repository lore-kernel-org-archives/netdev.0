From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 14:20:29 -0700
Message-ID: <1149110429.3078.5.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC041BC90@NT-IRVA-0751.brcm.ad.broadcom.com>
 <20060531045811.GA6977@gondor.apana.org.au>
 <20060530.221117.85394939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:36617 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S965212AbWEaXAI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 19:00:08 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060530.221117.85394939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-30 at 22:11 -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 31 May 2006 14:58:11 +1000
> 
> > Yes, TG3 does not disable IRQs when taking its TX lock.  So do you see
> > any problems with replacing the TG3 TX lock using xmit_lock?
> 
> I don't see any.
> 
David, So do we want to fix this issue as proposed by Herbert to replace
tx_lock with xmit_lock? It seems quite straightforward to do. For this
change to work, netpoll also needs to be fixed up a bit to check for
LLTX before getting the xmit_lock.

