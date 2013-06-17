From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tg3: Prevent system hang during repeated
 EEH errors.
Date: Mon, 17 Jun 2013 16:02:43 -0700 (PDT)
Message-ID: <20130617.160243.161622110613940981.davem@davemloft.net>
References: <1371502045-8044-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3FQXCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 19:02:44 -0400
In-Reply-To: <1371502045-8044-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Mon, 17 Jun 2013 13:47:25 -0700

> From: Michael Chan <mchan@broadcom.com>
> 
> The current tg3 code assumes the pci_error_handlers to be always called
> in sequence.  In particular, during ->error_detected(), NAPI is disabled
> and the device is shutdown.  The device is later reset and NAPI
> re-enabled in ->slot_reset() and ->resume().
> 
> In EEH, if more than 6 errors are detected in a hour, only
> ->error_detected() will be called.  This will leave the driver in an
> inconsistent state as NAPI is disabled but netif_running state is still
> true.  When the device is later closed, we'll try to disable NAPI again
> and it will loop forever.
> 
> We fix this by closing the device if we encounter any error conditions
> during the normal sequence of the pci_error_handlers.
> 
> v2: Remove the changes in tg3_io_resume() based on Benjamin Poirier's
>     feedback.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>

Applied, thanks.
