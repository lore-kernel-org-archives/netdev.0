From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Wed, 12 Jun 2013 00:23:13 +0200
Message-ID: <20130611222313.GA25499@electric-eye.fr.zoreil.com>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43776 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757583Ab3FKWXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 18:23:21 -0400
Content-Disposition: inline
In-Reply-To: <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> :
[...]
> I have heavily reworked the driver to be a bit saner, and
> in the process removed a number of features: TSO/GSO, VLAN
> acceleration and multiqueue. I've also ruthlessly stripped
> things not useful to me, e.g. register access support.
> 
> Right now it only supports a single TX and RX queue and no
> special features other than checksum offload.

- The bitops for alx->int_mask in alx_check_link and alx_poll race.
  ALX_ISR_{TX/RX}_Q0 may end disabled if alx_check_link wins.

- dev_alloc_skb is a bit legacy. You may netdev_alloc_skb (_ip_align ?).

- no spin_lock_init ?

- budget may not be honored in alx_clean_rx_irq

-- 
Ueimor
