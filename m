From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] caif-u5500: CAIF shared memory transport protocol
Date: Wed, 27 Oct 2010 11:07:32 -0700 (PDT)
Message-ID: <20101027.110732.48492064.davem@davemloft.net>
References: <1287774235-11151-1-git-send-email-sjur.brandeland@stericsson.com>
	<1287774235-11151-2-git-send-email-sjur.brandeland@stericsson.com>
	<1287774235-11151-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, sjurbr@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linus.walleij@stericsson.com,
	stefan.xk.nilsson@stericsson.com,
	amarnath.bangalore.revanna@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762Ab0J0SHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:07:08 -0400
In-Reply-To: <1287774235-11151-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Date: Fri, 22 Oct 2010 21:03:53 +0200

> +		if (!in_irq())
> +			spin_lock_bh(&pshm_drv->lock);
> +		else
> +			spin_lock_irqsave(&pshm_drv->lock, flags);

You should never have contextual based locking schemes like this,
it's not just ugly it's also deadlock prone.
