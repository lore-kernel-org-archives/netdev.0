From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 22:10:18 -0700 (PDT)
Message-ID: <20060605.221018.70218518.davem@davemloft.net>
References: <adapshmnbam.fsf@cisco.com>
	<adalksanb0c.fsf@cisco.com>
	<adahd2ynank.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38575
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932108AbWFFFKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 01:10:19 -0400
To: rdreier@cisco.com
In-Reply-To: <adahd2ynank.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 05 Jun 2006 21:57:51 -0700

>     Roland> You know, looking at the ipoib code, I can't even recreate
>     Roland> why xmit_lock is taken in the set_multicast_list method
>     Roland> anyway, or how it works at all -- it seems
>     Roland> set_multicast_list will always be called with xmit_lock
>     Roland> already held.  What the heck is going on?
> 
> Never mind -- I see that the set_multicast_list work needs to be
> deferred to process context, so ipoib_mcast_restart_task() doesn't run
> directly from the call to set_multicast_list.
> 
> I guess the fix in the current kernel is just something like the
> below.  And in the netif_tx_lock() patch, the local_irq_save() /
> local_irq_restore() calls can just be removed.
> 
> Am I on the right track?
> 
> Anyway I won't push the patch below since the bug is harmless right
> now and it can be fixed up as part of the netif_tx_lock() patch.

As long as you never take priv->lock while ->xmit_lock is held
your patch should be OK.
