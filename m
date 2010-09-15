From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Handle rxfifo errors on 8168 chips
Date: Thu, 16 Sep 2010 00:27:19 +0200
Message-ID: <20100915222719.GA13385@electric-eye.fr.zoreil.com>
References: <1284501431-23263-1-git-send-email-mjg@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jglisse@redhat.com
To: Matthew Garrett <mjg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 217.59.140-88.rev.gaoland.net ([88.140.59.217]:47739 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751809Ab0IOW1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 18:27:36 -0400
Content-Disposition: inline
In-Reply-To: <1284501431-23263-1-git-send-email-mjg@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Garrett <mjg@redhat.com> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 078bbf4..a0da4a1 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...]
> @@ -4625,8 +4625,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  		}
>  
>  		/* Work around for rx fifo overflow */
> -		if (unlikely(status & RxFIFOOver) &&
> -		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
> +		if (unlikely(status & RxFIFOOver)) {
>  			netif_stop_queue(dev);
>  			rtl8169_tx_timeout(dev);
>  			break;


Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Realtek's driver does something similar with the revision RTL_GIGA_MAC_VER_11
of the 8168.

-- 
Ueimor
